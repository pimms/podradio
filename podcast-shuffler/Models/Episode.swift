import Foundation
import UIKit
import ModernAVPlayer

struct Episode: Identifiable, Hashable {
    static let longDescription = "This description is way too long.\n - 1\n - 2\n - 3\n - 4\n\nAnd many more numbers :)\n\n💩\nhi mom"
    static let testData = [
        Episode(url: URL(string: "https://www.google.com")!, title: "Episode 1", description: longDescription, duration: 3650, date: Date().addingTimeInterval(-86400 * 50)),
        Episode(url: URL(string: "https://www.google.com")!, title: "Episode 2", description: "Den andre", duration: 1985, date: Date().addingTimeInterval(-86400 * 43)),
        Episode(url: URL(string: "https://www.google.com")!, title: "Episode 3", description: "Den tredje", duration: 3599, date: Date().addingTimeInterval(-86400 * 36)),
        Episode(url: URL(string: "https://www.google.com")!, title: "Episode 4", description: "Den fjerde", duration: 200, date: Date().addingTimeInterval(-86400 * 12)),
    ]

    var id: String { url.absoluteString }
    var url: URL
    var title: String
    var description: String
    var duration: TimeInterval
    var date: Date
}

extension Episode {
    var year: Int {
        let comps = Calendar.current.dateComponents([.year], from: date)
        return comps.year ?? 0
    }
}
