import Foundation

// MARK: - EpisodePicker

protocol EpisodePicker {
    var feed: Feed { get }
    func currentStreamable() -> Streamable
}

extension EpisodePicker {
    static func picker(for feed: Feed) -> EpisodePicker {
        fatalError("todo")
    }
}
