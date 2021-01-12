import Foundation

class BaseFilter: Filter {

    static private var cutoffDate: Date { Calendar.current.startOfDay(for: Date()) }

    // MARK: - Internal properties

    let feed: Feed

    var episodes: [Episode] {
        return feed.episodes.filter { $0.date < Self.cutoffDate }
    }

    // MARK: - Setup

    init(feed: Feed) {
        self.feed = feed
    }

}

extension BaseFilter: CustomStringConvertible {
    var description: String { "[DefaultFilter]" }
}
