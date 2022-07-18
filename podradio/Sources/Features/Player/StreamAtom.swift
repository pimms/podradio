import Foundation
import ModernAVPlayer

class StreamAtom: Equatable {
    let episode: Episode
    let startTime: Date

    private let generator: AtomGenerator

    init(generator: AtomGenerator, episode: Episode, startTime: Date) {
        self.generator = generator
        self.episode = episode
        self.startTime = startTime
    }

    static func == (lhs: StreamAtom, rhs: StreamAtom) -> Bool {
        return lhs.episode.url == rhs.episode.url
    }
}

extension StreamAtom {
    var title: String {
        return episode.title!
    }

    var description: String {
        return episode.detailedDescription ?? ""
    }

    var previousAtom: StreamAtom {
        generator.previousAtom(before: self)
    }

    var nextAtom: StreamAtom {
        generator.nextAtom(after: self)
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
