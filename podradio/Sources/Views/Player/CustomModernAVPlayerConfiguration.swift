import Foundation
import ModernAVPlayer
import AVFoundation

struct CustomModernAVPlayerConfiguration: PlayerConfiguration {
    var audioSessionCategoryOptions: AVAudioSession.CategoryOptions = []

    let allowsExternalPlayback: Bool = true
    let useDefaultRemoteCommand: Bool = false

    let rateObservingTimeout: TimeInterval
    let rateObservingTickTime: TimeInterval
    let preferredTimescale: CMTimeScale
    let periodicPlayingTime: CMTime
    let audioSessionCategory: AVAudioSession.Category
    let reachabilityURLSessionTimeout: TimeInterval
    let reachabilityNetworkTestingURL: URL
    let reachabilityNetworkTestingTickTime: TimeInterval
    let reachabilityNetworkTestingIteration: UInt
    let itemLoadedAssetKeys: [String]

    init() {
        let config = ModernAVPlayerConfiguration()

        rateObservingTimeout = config.rateObservingTimeout
        rateObservingTickTime = config.rateObservingTickTime
        preferredTimescale = config.preferredTimescale
        periodicPlayingTime = config.periodicPlayingTime
        audioSessionCategory = config.audioSessionCategory
        reachabilityURLSessionTimeout = config.reachabilityURLSessionTimeout
        reachabilityNetworkTestingURL = config.reachabilityNetworkTestingURL
        reachabilityNetworkTestingTickTime = config.reachabilityNetworkTestingTickTime
        reachabilityNetworkTestingIteration = config.reachabilityNetworkTestingIteration
        itemLoadedAssetKeys = config.itemLoadedAssetKeys
    }
}
