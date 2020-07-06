import Foundation

/// TODO
/// StreamPoints should be configured with a time offset.
/// The name is also quite rubbish.
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
