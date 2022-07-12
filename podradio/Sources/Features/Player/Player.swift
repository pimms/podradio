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
    @Published private(set) var feed: Feed?
    @Published private(set) var atom: StreamAtom?

    // MARK: - Private properties

    private var schedule: StreamSchedule?
    private var player: ModernAVPlayer
    private var subscription: AnyCancellable?

    // MARK: - Internal methods

    init() {
        player = ModernAVPlayer()
        player.delegate = self
        player.remoteCommands = [ makePlayCommand(), makeStopCommand(), makePlayPauseCommand() ]
    }

    func configure(with feed: Feed) {
        subscription?.cancel()
        subscription = nil

        let schedule = StreamSchedule(feed: feed)
        self.feed = feed
        self.schedule = schedule
        self.atom = nil
        loadAtomAndSeek(schedule.currentAtom(), autostart: false)

        subscription = feed.publisher(for: \.filter)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.filterReloaded()
            }
        )

    }

    func togglePlay() {
        guard let schedule else { fatalError() }
        switch playerState {
        case .readyToPlay:
            let currentAtom = schedule.currentAtom()
            if currentAtom == atom {
                print("▶️ The loaded asset is still relevant")
                player.seek(position: currentAtom.currentPosition)
                player.play()
            } else {
                print("▶️ The loaded asset has expired")
                loadAtomAndSeek(currentAtom, autostart: true)
            }

        case .playing, .waitingToPlay, .episodeTransition:
            player.pause()
            playerState = .paused
        case .paused, .none:
            startPlayer()
        }
    }

    func pause() {
        player.pause()
    }

    // MARK: - Private methods

    private func startPlayer() {
        guard let atom = schedule?.currentAtom() else { fatalError("Not configured") }
        loadAtomAndSeek(atom, autostart: true)
    }

    private func loadAtomAndSeek(_ atom: StreamAtom, autostart: Bool) {
        self.atom = atom
        let media = atom.media
        playerState = .waitingToPlay(autostart: autostart)
        player.load(media: media, autostart: false, position: atom.currentPosition)
    }
}

// MARK: - State transitions

extension Player {
    private func filterReloaded() {
        switch playerState {
        case .playing:
            startPlayer()
        default:
            atom = schedule?.currentAtom()
        }
    }

    private func playerLoaded() {
        guard let schedule else { fatalError() }
        guard let atom else { fatalError() }
        print("ℹ️ \(#function)")

        switch playerState {
        case .waitingToPlay(autostart: true),
             .episodeTransition:
            if player.currentTime >= atom.duration {
                print("❌ We loaded an expired asset, playing the current")
                loadAtomAndSeek(schedule.currentAtom(), autostart: true)
            } else {
                print("▶️ playing")
                player.play()
            }
        case .waitingToPlay(autostart: false):
            playerState = .readyToPlay
        default:
            return
        }
    }

    private func playerPlaying() {
        print("ℹ️ \(#function)")
        playerState = .playing
    }

    private func playerStopped() {
        print("ℹ️ \(#function)")
        guard let atom else { return }

        var nextAtom = atom.nextAtom
        while nextAtom.endTime < Date() {
            nextAtom = nextAtom.nextAtom
        }

        print("ℹ️ Beginning playback of atom '\(nextAtom.title)'")
        print("ℹ️   - startTime \(nextAtom.startTime.ISO8601Format()) (dt \(Date().timeIntervalSince1970 - nextAtom.startTime.timeIntervalSince1970)")
        print("ℹ️   - endTime \(nextAtom.endTime.ISO8601Format()) (dt \(Date().timeIntervalSince1970 - nextAtom.endTime.timeIntervalSince1970)")

        loadAtomAndSeek(nextAtom, autostart: true)
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
            print("⚠️ Unhandled ModernAVPlayer.State: \(state)")
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

}
