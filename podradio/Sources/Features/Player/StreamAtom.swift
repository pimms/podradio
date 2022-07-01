import Foundation
import ModernAVPlayer

class StreamAtom: Equatable {
    private let schedule: StreamScheduling

    let episode: Episode
    let startTime: Date

    init(schedule: StreamScheduling, episode: Episode, startTime: Date) {
        self.schedule = schedule
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
        schedule.previousAtom(before: self)
    }

    var nextAtom: StreamAtom {
        schedule.nextAtom(after: self)
    }

    var endTime: Date {
        startTime.addingTimeInterval(episode.duration)
    }

    var media: ModernAVPlayerMedia {
        ModernAVPlayerMedia(url: episode.url!, type: .clip)
    }

    var currentPosition: TimeInterval {
        let now = Date()
        let position = max(0, now.timeIntervalSince1970 - startTime.timeIntervalSince1970)
        return position
    }
}
