import Foundation
import ModernAVPlayer
import Combine

class Player: ObservableObject {
    enum PlayerState: Equatable {
        case none
        case waitingToPlay
        case playing
        case paused
    }

    // MARK: - Internal properties

    @Published private(set) var playerState: PlayerState = .none
    @Published private(set) var feed: Feed?
    @Published private(set) var atom: StreamAtom?

    // MARK: - Private properties

    private var schedule: StreamSchedule?
    private var player: ModernAVPlayer?
    private var subscription: AnyCancellable?

    // MARK: - Internal methods

    func configure(with feed: Feed) {
        self.player?.stop()
        self.player = nil
        self.atom = nil
        subscription?.cancel()
        subscription = nil

        self.feed = feed
        self.schedule = StreamSchedule(feed: feed)
        self.atom = schedule!.currentAtom()

        subscription = feed.publisher(for: \.filter)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.filterReloaded()
            }
        )

    }

    func togglePlay() {
        switch playerState {
        case .playing, .waitingToPlay:
            player?.pause()
            playerState = .paused
        case .paused, .none:
            startPlayer()
        }
    }

    func pause() {
        player?.pause()
    }

    // MARK: - Private methods

    private func startPlayer() {
        guard let schedule else { fatalError() }

        let atom = schedule.currentAtom()
        self.atom = atom

        let media = atom.media
        playerState = .waitingToPlay
        player = ModernAVPlayer()
        player?.delegate = self
        player?.load(media: media, autostart: false)
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
        guard let player, let atom else { return }
        guard playerState == .waitingToPlay else { return }

        let position = atom.currentPosition
        player.seek(position: position)
        player.play()
    }

    private func playerPlaying() {
        playerState = .playing
    }

    private func playerStopped() {
        print("[JDBG] \(#function)")
    }

    private func playerPaused() {
        playerState = .paused
    }

    private func playerFailed() {
        print("[JDBG] \(#function)")
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
            print("Unhandled ModernAVPlayer.State: \(state)")
        }
    }
}
