import Foundation
import UIKit

private let testImageUrl = URL(string: "https://cdn.pixabay.com/photo/2018/10/08/14/46/bird-3732867_1280.jpg")

struct Feed: Identifiable, Hashable {
    static let testData = [
        Feed(episodes: Episode.testData, title: "Feed 1", imageUrl: testImageUrl, url: URL(string: "https://www.google.com/1")!, lastRefreshDate: Date().addingTimeInterval(-80000)),
        Feed(episodes: Episode.testData, title: "Feed 2", imageUrl: testImageUrl, url: URL(string: "https://www.google.com/2")!, lastRefreshDate: Date().addingTimeInterval(-36000)),
    ]

    struct Section: Identifiable, Hashable {
        var id: String { title }
        var title: String
        var episodes: [Episode]
    }

    typealias Id = Int

    var id: Id { Int(url.absoluteString.uppercased().stableHash) }
    var episodes: [Episode] { didSet { rebuildSections() } }
    var title: String
    var imageUrl: URL?
    var url: URL
    var lastRefreshDate: Date
    private(set) var sections: [Section]

    init(episodes: [Episode], title: String, imageUrl: URL?, url: URL, lastRefreshDate: Date) {
        self.episodes = episodes
        self.title = title
        self.imageUrl = imageUrl
        self.url = url
        self.sections = []
        self.lastRefreshDate = lastRefreshDate

        rebuildSections()
    }
}


private extension Feed {
    struct YearAndMonth: Hashable {
        let year: Int
        let month: Int

        var sortValue: Int { year*12 + month }
    }

    private mutating func rebuildSections() {
        let tuple = episodes
            .map { (episode: Episode) -> (YearAndMonth, Episode) in
                let components = Calendar.current.dateComponents([.year, .month], from: episode.date)
                let yearAndMonth = YearAndMonth(year: components.year ?? 2010, month: components.month ?? 0)
                return (yearAndMonth, episode)
            }

        if episodes.count > 300 {
            buildMonthlySections(from: tuple)
        } else {
            buildYearlySections(from: tuple)
        }
    }

    private mutating func buildYearlySections(from tuple: [(YearAndMonth, Episode)]) {
        let dict = Dictionary(grouping: tuple, by: { $0.0.year })
        self.sections = dict.keys
            .sorted { $0 < $1 }
            .map { key in
                let episodes = dict[key]!.reduce(into: [], { result, tuple in result.append(tuple.1)})
                return Section(title: "\(key)", episodes: episodes)
            }
    }

    private mutating func buildMonthlySections(from tuple: [(YearAndMonth, Episode)]) {
        let dict = Dictionary(grouping: tuple, by: { $0.0 })

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"

        self.sections = dict.keys
            .sorted { $0.sortValue < $1.sortValue }
            .map { key in
                var episodes: [Episode] = []
                for episode in dict[key] ?? [] {
                    episodes.append(episode.1)
                }

                let title = dateFormatter.string(from: episodes[0].date)
                return Section(title: title, episodes: episodes)
            }
    }
}
