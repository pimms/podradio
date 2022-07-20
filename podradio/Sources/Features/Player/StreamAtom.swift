import Foundation
import ModernAVPlayer

class StreamAtom: Hashable, Identifiable {
    var id: any Hashable { self }

    let episode: Episode
    let startTime: Date

    init(episode: Episode, startTime: Date) {
        self.episode = episode
        self.startTime = startTime
    }

    static func == (lhs: StreamAtom, rhs: StreamAtom) -> Bool {
        return lhs.episode.url == rhs.episode.url
            && lhs.startTime == rhs.startTime
    }

    func hash(into hasher: inout Hasher) {
        episode.url!.hash(into: &hasher)
        startTime.hash(into: &hasher)
    }
}

extension StreamAtom {
    var title: String {
        return episode.title!
    }

    var description: String {
        return episode.detailedDescription ?? ""
    }

    var endTime: Date {
        startTime.addingTimeInterval(episode.duration)
    }

    var duration: TimeInterval {
        episode.duration
    }

    var media: ModernAVPlayerMedia {
        ModernAVPlayerMedia(url: episode.url!, type: .stream(isLive: true))
    }

    var currentPosition: TimeInterval {
        let now = Date()
        let position = max(0, now.timeIntervalSince1970 - startTime.timeIntervalSince1970)
        return position
    }
}
