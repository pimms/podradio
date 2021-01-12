import Foundation

class YearFilter: Filter {

    // MARK: - Internal properties

    let feed: Feed
    let episodes: [Episode]
    let years: [Int]

    // MARK: - Setup

    init(feed: Feed, years: [Int]) {
        self.feed = feed
        self.episodes = BaseFilter(feed: feed).episodes.filter { years.contains($0.year) }
        self.years = years
    }
}

extension YearFilter: CustomStringConvertible {
    var description: String { "[YearFilter(\(years))]" }
}
