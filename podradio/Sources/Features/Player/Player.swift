import Foundation
import ModernAVPlayer
import MediaPlayer
import Combine

class Player: ObservableObject {
    enum PlayerState: Equatable {
        case none
        case episodeTransition
        case waitingToPlay(autostart: Bool)
        case readyToPlay
        case playing
        case paused
    }

    // MARK: - Internal properties

    @Published private(set) var playerState: PlayerState = .none {
        didSet {
            print("🍖 playerState changed: \(playerState)")
        }
    }
    var feed: Feed? { schedule?.feed }

    // MARK: - Private properties

    private var schedule: StreamSchedule?
    private var player: ModernAVPlayerExposable
    private var currentTimeSubscription: AnyCancellable?
    private var atomChangeSubscription: AnyCancellable?

    // MARK: - Internal methods

    init(dummyPlayer: Bool = false) {
        if dummyPlayer {
            player = DummyModernAVPlayer()
        } else {
            let player = ModernAVPlayer(config: CustomModernAVPlayerConfiguration())
            self.player = player
            player.delegate = self
            player.remoteCommands = [ makePlayCommand(), makeStopCommand(), makePlayPauseCommand() ]
        }
    }

    func isConfigured(with schedule: StreamSchedule) -> Bool {
        return self.schedule == schedule
    }

    func configureIfUnconfigured(with schedule: StreamSchedule) {
        if self.schedule == nil {
            configure(with: schedule)
        }
    }

    func ensureConfigured(with schedule: StreamSchedule) {
        if self.schedule != schedule {
            configure(with: schedule)
        }
    }

    func configure(with schedule: StreamSchedule) {
        self.schedule = schedule
        playerState = .none

        if !isRunningPreviews() {
            atomChangeSubscription?.cancel()
            atomChangeSubscription = schedule.$atom
                .dropFirst()
                .sink(receiveValue: { [weak self] _ in
                    self?.onAtomChanged()
                })
        }
    }

    func togglePlay() {
        guard let schedule else { fatalError() }
        switch playerState {
        case .readyToPlay, .paused, .none:
            loadAtomAndSeek(schedule.atom, autostart: true)
        case .waitingToPlay(autostart: false):
            playerState = .waitingToPlay(autostart: true)
        case .playing, .waitingToPlay(autostart: true), .episodeTransition:
            player.pause()
        }
    }

    func pause() {
        player.pause()
    }

    // MARK: - Private methods

    private func loadAtomAndSeek(_ atom: StreamAtom, autostart: Bool) {
        let media = atom.media
        playerState = .waitingToPlay(autostart: autostart)
        player.load(media: media, autostart: false, position: atom.currentPosition)
    }

    private func onAtomChanged() {
        print("ℹ️ \(#function)")
        DispatchQueue.main.async {
            guard let atom = self.schedule?.atom else { fatalError() }

            switch self.playerState {
            case .playing, .episodeTransition:
                self.loadAtomAndSeek(atom, autostart: true)
            default:
                self.loadAtomAndSeek(atom, autostart: false)
            }
        }
    }
}

// MARK: - State transitions

extension Player {
    private func playerLoaded() {
        print("ℹ️ \(#function)")

        switch playerState {
        case .waitingToPlay(autostart: true),
             .episodeTransition:
            print("▶️ playing")
            player.play()
        case .waitingToPlay(autostart: false):
            playerState = .readyToPlay
        default:
            return
        }
    }

    private func playerPlaying() {
        print("ℹ️ \(#function)")
        playerState = .playing
        player.updateMetadata(makeMetadata())
    }

    private func playerStopped() {
        print("ℹ️ \(#function) - waiting for StreamSchedule to give us the next atom")
        playerState = .episodeTransition
    }

    private func playerPaused() {
        playerState = .paused
    }

    private func playerFailed() {
        print("ℹ️ \(#function)")
    }
}

// MARK: - ModernAVPlayerDelegate

extension Player: ModernAVPlayerDelegate {
    func modernAVPlayer(_ player: ModernAVPlayer, didStateChange state: ModernAVPlayer.State) {
        switch state {
        case .loaded:
            playerLoaded()
        case .playing:
            playerPlaying()
        case .stopped:
            playerStopped()
        case .paused:
            playerPaused()
        case .failed:
            playerFailed()
        default:
            break
        }
    }
}

// MARK: - Remote Commands

extension Player {
    private func makePlayCommand() -> ModernAVPlayerRemoteCommand {
        let command = MPRemoteCommandCenter.shared().playCommand
        let isEnabled: (MediaType) -> Bool = { _ in return true }

        let handler: (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus = { [weak self] _ in
            self?.togglePlay()
            return .success
        }

        command.addTarget(handler: handler)
        return ModernAVPlayerRemoteCommand(reference: command, debugDescription: "PodRadio-play", isEnabled: isEnabled)
    }

    private func makePlayPauseCommand() -> ModernAVPlayerRemoteCommand {
        let command = MPRemoteCommandCenter.shared().togglePlayPauseCommand
        let isEnabled: (MediaType) -> Bool = { _ in return true }

        let handler: (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus = { [weak self] _ in
            self?.togglePlay()
            return .success
        }

        command.addTarget(handler: handler)
        return ModernAVPlayerRemoteCommand(reference: command, debugDescription: "PodRadio-togglePlayPause", isEnabled: isEnabled)
    }

    private func makeStopCommand() -> ModernAVPlayerRemoteCommand {
        let command = MPRemoteCommandCenter.shared().stopCommand
        let isEnabled: (MediaType) -> Bool = { _ in return true }

        let handler: (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus = { [weak self] _ in
            self?.pause()
            return .success
        }

        command.addTarget(handler: handler)
        return ModernAVPlayerRemoteCommand(reference: command, debugDescription: "PodRadio-stop", isEnabled: isEnabled)
    }

    private func makeMetadata() -> ModernAVPlayerMediaMetadata {
        guard let schedule else { fatalError() }

        var albumTitle: String?

        if let year = Calendar.current.dateComponents([.year], from: schedule.atom.episode.publishDate!).year {
            albumTitle = "\(year)"
        }

        return ModernAVPlayerMediaMetadata(
            title: schedule.atom.title,
            albumTitle: albumTitle,
            artist: schedule.feed.title!,
            remoteImageUrl: schedule.feed.imageUrl)
    }
}
