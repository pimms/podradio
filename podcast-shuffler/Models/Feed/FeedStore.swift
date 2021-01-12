import Foundation

import SwiftUI

class FeedStore: ObservableObject {
    static let testStore = FeedStore(feeds: Feed.testData)

    // MARK: - Internal properties

    @Published var feeds: [Feed]
    @Published var feedsLoaded: Bool = false

    // MARK: - Private properties

    private lazy var log = Log(self)
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

    // MARK: - Internal methods

    func addFeed(from url: URL, then completion: ((Bool) -> Void)? = nil) {
        log.debug("Adding feed '\(url.absoluteString)'")
        if let id = ITunesIdExtractor().extractId(from: url) {
            log.debug("iTunes link with ID \(id)")
            let linkExtractor = ITunesLinkExtractor(httpClient: httpClient)
            linkExtractor.extractLink(forId: id) { result in
                switch result {
                case .success(let itunesUrl):
                    self.log.debug("Extracted iTunes URL '\(itunesUrl.absoluteString)'")
                    self.addRssFeed(from: itunesUrl, then: completion)
                case .failure:
                    self.log.error("Failed to extract iTunes URL")
                    completion?(false)
                }
            }
        } else {
            addRssFeed(from: url, then: completion)
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

    func refreshFeeds(olderThan date: Date) {
        feedCache.cache.forEach { cacheEntry in
            if cacheEntry.lastRefreshed < date {
                httpClient.get(cacheEntry.feedUrl) { [weak self] response in
                    switch response {
                    case .success(let data):
                        self?.log.debug("Refreshed feed '\(cacheEntry.feedUrl)'")
                        self?.handleFeedData(url: cacheEntry.feedUrl, data: data)
                    case .failure(let err):
                        self?.log.error("Failed to refresh feed '\(cacheEntry.feedUrl)': \(err)")
                    }
                }
            }
        }
    }

    // MARK: - Private methods

    private func loadCachedFeeds() {
        var tempFeeds = [Feed]()
        feedCache.cache.forEach { cacheEntry in
            guard let data = cacheEntry.feedContent,
                  let feed = FeedParser.parseRssData(data, url: cacheEntry.feedUrl) else {
                feedCache.remove(cacheEntry)
                return
            }

            tempFeeds.append(feed)
        }

        DispatchQueue.main.async {
            self.feeds = tempFeeds
            self.feedsLoaded = true
            self.feeds.forEach { feed in
                self.log.debug(" - \(feed.title)")
                self.log.debug("   \(feed.id)")
                self.log.debug("   \(feed.url)")
            }
        }
    }

    private func addRssFeed(from url: URL, then completion: ((Bool) -> Void)?) {
        guard let httpsUrl = url.withHttps else {
            completion?(false)
            return
        }

        guard feedCache.cache.filter({ $0.feedUrl == httpsUrl }).isEmpty else {
            log.debug("Feed '\(httpsUrl.absoluteString)' already exists in cache")
            completion?(true)
            return
        }

        httpClient.get(httpsUrl) { [weak self] response in
            switch response {
            case .success(let data):
                guard let self = self else { return }
                let result = self.handleFeedData(url: httpsUrl, data: data)
                DispatchQueue.main.async {
                    completion?(result)
                }
            case .failure:
                DispatchQueue.main.async {
                    completion?(false)
                }
            }
        }
    }

    @discardableResult
    private func handleFeedData(url: URL, data: Data?) -> Bool {
        guard let data = data, let feed = FeedParser.parseRssData(data, url: url) else {
            return false
        }

        self.feedCache.cacheFeed(url, feedContent: data)

        DispatchQueue.syncOnMain {
            if let existingIndex = feeds.firstIndex(where: { $0.id == feed.id }) {
                feeds[existingIndex] = feed
            } else {
                self.feeds.append(feed)
            }
        }
        return true
    }
}
