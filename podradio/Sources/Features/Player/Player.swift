import Foundation
import ModernAVPlayer
import Combine

class Player: ObservableObject {
    enum PlayerState: Equatable {
        case none
        case episodeTransition
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
        case .playing, .waitingToPlay, .episodeTransition:
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
        guard playerState == .waitingToPlay || playerState == .episodeTransition else { return }
        print("[JDBG] \(#function)")

        let position = atom.currentPosition
        player.seek(position: position)
        player.play()
        print("[JDBG] Seeking to \(position)")
    }

    private func playerPlaying() {
        playerState = .playing
    }

    private func playerStopped() {
        print("[JDBG] \(#function)")
        guard let atom else { return }

        var nextAtom = atom.nextAtom
        while nextAtom.endTime < Date() {
            nextAtom = nextAtom.nextAtom
        }

        print("[JDBG] Beginning playback of atom '\(nextAtom.title)'")
        print("[JDBG]  - startTime \(nextAtom.startTime.ISO8601Format()) (dt \(Date().timeIntervalSince1970 - nextAtom.startTime.timeIntervalSince1970)")
        print("[JDBG]  - endTime \(nextAtom.endTime.ISO8601Format()) (dt \(Date().timeIntervalSince1970 - nextAtom.endTime.timeIntervalSince1970)")

        self.atom = nextAtom
        playerState = .episodeTransition
        player?.load(media: nextAtom.media, autostart: true)
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
