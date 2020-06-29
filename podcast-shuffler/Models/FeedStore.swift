import Foundation

import SwiftUI

class FeedStore: ObservableObject {
    static let testStore = FeedStore(feeds: Feed.testData)

    // MARK: - Internal properties

    @Published var feeds: [Feed]

    // MARK: - Private properties

    private let feedProvider: FeedProvider?

    // MARK: - Init

    init(feeds: [Feed]) {
        self.feeds = feeds
        self.feedProvider = nil
    }

    init() {
        // now what lol ¯\_(ツ)_/¯
        self.feeds = []
        self.feedProvider = FeedProvider()
    }

    // MARK: - Internal methods

    func addFeed(from url: URL, then completion: ((Bool) -> Void)? = nil) {
        feedProvider?.downloadFeed(at: url) { [weak self] result in
            switch result {
            case .success(let feed):
                self?.feeds.append(feed)
                completion?(true)
            case .failure(let error):
                // TODO: How do we notify someone about this?
                print("Failed to add feed: \(error)")
                completion?(false)
            }
        }
    }
}
