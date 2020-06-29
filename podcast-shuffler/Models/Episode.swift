import Foundation
import UIKit

struct Episode: Identifiable {
    static let testData = [
        Episode(url: URL(string: "https://www.google.com")!, title: "Episode 1", description: "Den første", date: Date().addingTimeInterval(-86400 * 50)),
        Episode(url: URL(string: "https://www.google.com")!, title: "Episode 2", description: "Den andre", date: Date().addingTimeInterval(-86400 * 43)),
        Episode(url: URL(string: "https://www.google.com")!, title: "Episode 3", description: "Den tredje", date: Date().addingTimeInterval(-86400 * 36))
    ]

    var id: String { url.absoluteString }
    var url: URL
    var title: String
    var description: String
    var date: Date
}
