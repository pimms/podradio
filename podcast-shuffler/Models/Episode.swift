import Foundation
import UIKit

struct Episode: Identifiable {
    static let testData = [
        Episode(url: URL(string: "https://www.google.com")!, title: "Episode 1", description: "Den første", duration: 3650, date: Date().addingTimeInterval(-86400 * 50)),
        Episode(url: URL(string: "https://www.google.com")!, title: "Episode 2", description: "Den andre", duration: 1985, date: Date().addingTimeInterval(-86400 * 43)),
        Episode(url: URL(string: "https://www.google.com")!, title: "Episode 3", description: "Den tredje", duration: nil, date: Date().addingTimeInterval(-86400 * 36))
    ]

    var id: String { url.absoluteString }
    var url: URL
    var title: String
    var description: String
    var duration: TimeInterval?
    var date: Date
}
