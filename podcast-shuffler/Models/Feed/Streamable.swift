import Foundation

protocol Streamable {
    var episode: Episode { get }
    var nextStreamable: Streamable { get }
    var previousStreamable: Streamable { get }
    var startTime: Date { get }
}

extension Streamable {
    var endTime: Date {
        return startTime.addingTimeInterval(episode.duration)
    }
}
