import Foundation

protocol Filter {
    var feed: Feed { get }
    var episodes: [Episode] { get }
}
