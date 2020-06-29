import Foundation
import UIKit

struct Feed: Identifiable {
    static let testData = [
        Feed(id: "1", episodes: Episode.testData, title: "Feed 1", image: nil, url: URL(string: "https://www.google.com")!),
        Feed(id: "2", episodes: Episode.testData, title: "Feed 2", image: nil, url: URL(string: "https://www.google.com")!),
    ]

    struct Section: Identifiable {
        var id: String { title }
        var title: String
        var episodes: [Episode]
    }

    var id: String
    var episodes: [Episode] { didSet { rebuildSections() } }
    var title: String
    var image: UIImage?
    var url: URL
    private(set) var sections: [Section]

    init(id: String, episodes: [Episode], title: String, image: UIImage?, url: URL) {
        self.id = id
        self.episodes = episodes
        self.title = title
        self.image = image
        self.url = url
        self.sections = []

        rebuildSections()
    }
}


private extension Feed {
    struct YearAndMonth: Hashable {
        let year: Int
        let month: Int
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
            .sorted { $0.year < $1.year && $0.month < $1.month }
            .map { key in
                let episodes = dict[key]!.reduce(into: [], { result, tuple in result.append(tuple.1)})
                let title = dateFormatter.string(from: episodes[0].date)
                return Section(title: title, episodes: episodes)
            }
    }
}
