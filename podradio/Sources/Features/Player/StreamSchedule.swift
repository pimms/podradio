import Foundation

class StreamSchedule: Equatable {

    // MARK: - Static

    static func == (lhs: StreamSchedule, rhs: StreamSchedule) -> Bool {
        return lhs.feed == rhs.feed
    }

    // MARK: - Internal properties

    private(set) var feed: Feed

    // MARK: - Private properties

    private let generator: AtomGenerator

    // MARK: - Init

    init(feed: Feed) {
        self.feed = feed
        self.generator = AtomGenerator(feed: feed)
    }

    // MARK: - Internal methods

    func updateFeed(_ feed: Feed) {
        guard feed.url! == self.feed.url! else { fatalError() }
        self.feed = feed
        generator.clearCache()
    }

    func currentAtom() -> StreamAtom {
        generator.currentAtom()
    }
}
