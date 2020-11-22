import Foundation
import AVFoundation
import ModernAVPlayer

class EpisodePlayer: ObservableObject {
    static var current: EpisodePlayer?

    enum State {
        case playing
        case paused
    }

    // MARK: - Published properties

    @Published var currentEpisode: Episode?
    @Published var state: State = .paused

    // MARK: - Internal properties

    var duration: TimeInterval { 0 }
    var currentTime: TimeInterval { 0 }

    // MARK: - Private properties

    private let player: ModernAVPlayer
    private var episodePicker: EpisodePicker?
    private var streamable: Streamable?

    private var isTransitioningToNextEpisode = false

    private var isCurrent: Bool { Self.current === self }

    // MARK: - Lifecycle

    init() {
        let config = ModernAVPlayerConfiguration()
        player = ModernAVPlayer(config: config, loggerDomains: [.error, .service, .remoteCommand])
        player.delegate = self

        let commandFactory = ModernAVPlayerRemoteCommandFactory(player: player)
        player.remoteCommands = [ commandFactory.playCommand ]
    }

    // MARK: - Internal methods

    func configure(with picker: EpisodePicker) {
        let streamable = picker.currentStreamable()
        self.episodePicker = picker
        self.streamable = streamable

        let url = streamable.episode.url
        let media = ModernAVPlayerMedia(url: url, type: .clip)

        let position = streamable.startTime.distance(to: Date())
        player.load(media: media, autostart: false, position: position)

        print("[EpisodePlayer] Loading episode: \(url.absoluteString) at position \(position)")

        DispatchQueue.main.async {
            self.currentEpisode = streamable.episode
        }
    }

    func pause() {
        player.pause()
    }

    func play() {
        guard let streamable = streamable else { fatalError("No streamable") }

        makeCurrent()

        let position = streamable.startTime.distance(to: Date())
        print("[EpisodePicker] Playing from position \(position)")

        player.seek(position: position)
        player.play()
    }

    // MARK: - Private methods

    private func makeCurrent() {
        if !isCurrent {
            Self.current?.pause()
            Self.current = self
        }
    }

    private func makeMetadata() -> ModernAVPlayerMediaMetadata? {
        guard let episode = streamable?.episode else { return nil }
        guard let feed = episodePicker?.feed else { return nil }

        var albumTitle: String?
        if let year = Calendar.current.dateComponents([.year], from: episode.date).year {
            albumTitle = "\(year)"
        }

        return ModernAVPlayerMediaMetadata(title: episode.title,
                                           albumTitle: albumTitle,
                                           artist: feed.title)
    }
}

extension EpisodePlayer: ModernAVPlayerDelegate {
    func modernAVPlayer(_ player: ModernAVPlayer, didStateChange state: ModernAVPlayer.State) {
        switch state {
        case .playing:
            player.updateMetadata(makeMetadata())
            self.state = .playing
        case .buffering,
             .initialization,
             .loading:
            self.state = .playing
        case .failed,
             .loaded,
             .paused,
             .stopped,
             .waitingForNetwork:
            self.state = .paused
        }
        print("[EpisodePlayer] State changed: \(state)")

        // When an episode ends and we reconfigure the player, autoplay doesn't
        // seem to function properly, so we need to handle the transition ourselves.
        // After loading the next episode, we enter the "stopped" state, from which
        // we can start playing the next episode.
        if state == .stopped, isTransitioningToNextEpisode {
            isTransitioningToNextEpisode = false
            play()
        }
    }

    func modernAVPlayer(_ player: ModernAVPlayer, didCurrentMediaChange media: PlayerMedia?) {
        print("[EpisodePlayer] Current media changed: \(media?.url.absoluteString ?? "<nil>")")
    }

    func modernAVPlayer(_ player: ModernAVPlayer, didCurrentTimeChange currentTime: Double) {

    }

    func modernAVPlayer(_ player: ModernAVPlayer, didItemDurationChange itemDuration: Double?) {
        print("[EpisodePlayer] Item duration changed: \(itemDuration ?? -1)")
    }

    func modernAVPlayer(_ player: ModernAVPlayer, unavailableActionReason: PlayerUnavailableActionReason) {
        print("[EpisodePlayer] Unavailable action: \(unavailableActionReason)")
    }

    func modernAVPlayer(_ player: ModernAVPlayer, didItemPlayToEndTime endTime: Double) {
        player.stop()
        if let episodePicker = episodePicker {
            isTransitioningToNextEpisode = true
            configure(with: episodePicker)
        }
    }
}
