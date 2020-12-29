import Foundation

import SwiftUI

class FeedStore: ObservableObject {
    static let testStore = FeedStore(feeds: Feed.testData)

    // MARK: - Internal properties

    @Published var feeds: [Feed]

    // MARK: - Private properties

    private let feedCache = FeedCache()
    private let httpClient = HttpClient()

    // MARK: - Init

    init(feeds: [Feed]) {
        self.feeds = feeds
    }

    init() {
        self.feeds = []
        loadCachedFeeds()
    }

    private func loadCachedFeeds() {
        feedCache.cache.forEach { cacheEntry in
            guard let data = cacheEntry.feedContent,
                  let feed = FeedParser.parseRssData(data, url: cacheEntry.feedUrl) else {
                feedCache.remove(cacheEntry)
                return
            }

            DispatchQueue.main.async {
                self.feeds.append(feed)
            }
        }
    }

    // MARK: - Internal methods

    func addFeed(from url: URL, then completion: ((Bool) -> Void)? = nil) {
        httpClient.get(url) { [weak self] response in
            switch response {
            case .success(let data):
                guard let data = data,
                      let feed = FeedParser.parseRssData(data, url: url) else {
                    DispatchQueue.main.async {
                        completion?(false)
                    }
                    return
                }

                self?.feedCache.cacheFeed(url, feedContent: data)
                DispatchQueue.main.async {
                    self?.feeds.append(feed)
                    completion?(true)
                }
            case .failure:
                DispatchQueue.main.async {
                    completion?(false)
                }
            }
        }
    }

    func deleteFeed(_ feed: Feed) {
        feedCache.cache
            .filter { $0.feedUrl == feed.url }
            .forEach { feedCache.remove($0) }

        DispatchQueue.syncOnMain {
            feeds = feeds.filter { $0.id != feed.id }
        }
    }
}
