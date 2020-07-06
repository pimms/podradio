import Foundation
import AVFoundation

class EpisodePlayer: ObservableObject {

    // MARK: - Published properties

    @Published var currentEpisode: Episode?

    // MARK: - Internal properties

    var duration: TimeInterval { player?.currentItem?.asset.duration.seconds ?? 0 }
    var currentTime: TimeInterval { player?.currentItem?.currentTime().seconds ?? 0 }

    // MARK: - Private properties

    private var playerItem: AVPlayerItem?
    private var player: AVPlayer?
    private var streamable: Streamable?

    // MARK: - Internal methods

    func configure(with picker: EpisodePicker) {
        pause()

        let streamable = picker.currentStreamable()
        self.streamable = streamable

        playerItem = AVPlayerItem(url: streamable.episode.url)
        player = AVPlayer(playerItem: playerItem)
        print("Playing episode \(streamable.episode.url.absoluteString)")

        DispatchQueue.main.async {
            self.currentEpisode = streamable.episode
        }

        play()
    }

    func pause() {
        player?.pause()
    }

    func play() {
        player?.play()
    }
}
