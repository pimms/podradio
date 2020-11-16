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
    private var statusObserver: NSKeyValueObservation?

    // MARK: - Lifecycle

    deinit {
        statusObserver?.invalidate()
    }

    // MARK: - Internal methods

    func configure(with picker: EpisodePicker) {
        pause()

        let streamable = picker.currentStreamable()
        self.streamable = streamable

        let asset = AVAsset(url: streamable.episode.url)
        playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: ["playable", "duration"])
        player = AVPlayer(playerItem: playerItem)
        statusObserver = playerItem?.observe(\.status, options: [.new]) { _, status in
            switch self.player?.status {
            case .readyToPlay:
                print("READY TO PLAY")
                self.play()
            default:
                break
            }
        }

        print("Playing episode \(streamable.episode.url.absoluteString)")

        DispatchQueue.main.async {
            self.currentEpisode = streamable.episode
        }
    }

    func pause() {
        player?.pause()
    }

    func play() {
        guard let streamable = streamable else { fatalError("No streamable") }

        self.player?.play()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            print("-- attempting to seek --")
            let diff = streamable.startTime.distance(to: Date())
            let cmTime = CMTime(seconds: diff, preferredTimescale: 1000)
            self.player?.seek(to: cmTime, completionHandler: { success in
                print("seek success: \(success)")
            })
        }
    }
}
