import Foundation

class YearFilter: Filter {

    // MARK: - Internal methods

    let feed: Feed
    let episodes: [Episode]
    let years: [Int]

    // MARK: - Setup

    init(feed: Feed, years: [Int]) {
        self.feed = feed
        self.episodes = feed.episodes.filter { years.contains($0.year) }
        self.years = years
    }
}
