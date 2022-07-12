import Foundation
import ModernAVPlayer
import AVFoundation

class DummyModernAVPlayer: ModernAVPlayerExposable {
    var currentMedia: PlayerMedia? { nil }

    var currentTime: Double { 0 }

    var loopMode: Bool = false

    var player: AVPlayer { fatalError() }

    var remoteCommands: [ModernAVPlayerRemoteCommand]? { nil }

    var state: ModernAVPlayer.State { .stopped }

    func updateMetadata(_ metadata: PlayerMediaMetadata?) { }

    func load(media: PlayerMedia, autostart: Bool, position: Double?) { }

    func pause() { }

    func play() { }

    func seek(position: Double) { }

    func stop() { }
}
