import Foundation

class DefaultFilter: Filter {

    // MARK: - Internal properties

    let feed: Feed

    var episodes: [Episode] {
        return feed.episodes
    }

    // MARK: - Setup

    init(feed: Feed) {
        self.feed = feed
    }
}
