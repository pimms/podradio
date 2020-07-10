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
        self.feeds = []
        self.feedProvider = FeedProvider()
        addPersistentFeeds()
    }

    // MARK: - Internal methods

    func addFeed(from url: URL, then completion: ((Bool) -> Void)? = nil) {
        feedProvider?.downloadFeed(at: url) { [weak self] result in
            DispatchQueue.main.async {
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

    // MARK: - Private methods

    private func addPersistentFeeds() {
        feedProvider?.persistentFeedUrls.forEach { [weak self] url in
            feedProvider?.downloadFeed(at: url, handler: { result in
                switch result {
                case .success(let feed):
                    DispatchQueue.main.async {
                        self?.feeds.append(feed)
                    }
                case .failure(let error):
                    print("Failed to add persistent feed: \(error)")
                }
            })
        }
    }
}
