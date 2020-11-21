import Foundation
import AVFoundation
import ModernAVPlayer

class EpisodePlayer: ObservableObject {

    // MARK: - Published properties

    @Published var currentEpisode: Episode?

    // MARK: - Internal properties

    var duration: TimeInterval { 0 }
    var currentTime: TimeInterval { 0 }

    // MARK: - Private properties

    private let player = ModernAVPlayer()
    private var streamable: Streamable?

    // MARK: - Lifecycle

    // MARK: - Internal methods

    func configure(with picker: EpisodePicker) {
        pause()

        let streamable = picker.currentStreamable()
        self.streamable = streamable

        let url = streamable.episode.url
        let media = ModernAVPlayerMedia(url: url, type: .clip)

        let position = streamable.startTime.distance(to: Date())
        player.load(media: media, autostart: true, position: position)

        print("Playing episode \(media.url.absoluteString)")

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
