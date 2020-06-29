import Foundation
import UIKit

struct Feed: Identifiable {
    static let testData = [
        Feed(id: "1", episodes: Episode.testData, title: "Feed 1", image: nil),
        Feed(id: "2", episodes: Episode.testData, title: "Feed 2", image: nil),
    ]

    var id: String
    var episodes: [Episode]
    var title: String
    var image: UIImage?
}
