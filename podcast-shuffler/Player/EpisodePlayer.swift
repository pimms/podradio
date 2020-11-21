import Foundation
import AVFoundation
import ModernAVPlayer

class EpisodePlayer: ObservableObject {
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

    // MARK: - Lifecycle

    init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[EpisodePlayer] AVAudioSession failure: \(error)")
        }

        let config = ModernAVPlayerConfiguration()
        player = ModernAVPlayer(config: config)

        let commandFactory = ModernAVPlayerRemoteCommandFactory(player: player)
        player.remoteCommands = [
            commandFactory.playCommand,
            commandFactory.pauseCommand,
            commandFactory.togglePlayPauseCommand,
        ]
    }

    // MARK: - Internal methods

    func configure(with picker: EpisodePicker) {
        pause()

        let streamable = picker.currentStreamable()
        self.episodePicker = picker
        self.streamable = streamable

        let url = streamable.episode.url
        let metadata = ModernAVPlayerMediaMetadata(title: "RR", albumTitle: "pls", artist: "Radioresepsjonen")
        let media = ModernAVPlayerMedia(url: url, type: .clip, metadata: metadata)
        player.updateMetadata(metadata)

        let position = streamable.startTime.distance(to: Date())
        player.load(media: media, autostart: false, position: position)
        player.delegate = self

        DispatchQueue.main.async {
            self.currentEpisode = streamable.episode
        }
    }

    func pause() {
        player.pause()
    }

    func play() {
        guard let streamable = streamable else { fatalError("No streamable") }

        let position = streamable.startTime.distance(to: Date())
        player.seek(position: position)
        player.play()
    }
}

extension EpisodePlayer: ModernAVPlayerDelegate {
    func modernAVPlayer(_ player: ModernAVPlayer, didStateChange state: ModernAVPlayer.State) {
        switch state {
        case .buffering,
             .initialization,
             .loading,
             .playing:
            self.state = .playing
        case .failed,
             .loaded,
             .paused,
             .stopped,
             .waitingForNetwork:
            self.state = .paused
        }
        print("[EpisodePlayer] State changed: \(state)")
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
        print("[EpisodePlayer] Item completed")
        if let episodePicker = episodePicker {
            configure(with: episodePicker)
        }
    }
}
