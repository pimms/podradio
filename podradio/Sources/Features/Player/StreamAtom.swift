import Foundation
import ModernAVPlayer

class StreamAtom {
    private let schedule: StreamSchedule

    let episode: Episode
    let startTime: Date

    init(schedule: StreamSchedule, episode: Episode, startTime: Date) {
        self.schedule = schedule
        self.episode = episode
        self.startTime = startTime
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
        schedule.streamable(before: self)
    }

    var nextAtom: StreamAtom {
        schedule.streamable(after: self)
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
