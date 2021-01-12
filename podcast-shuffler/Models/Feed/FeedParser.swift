import Foundation
import FeedKit

final class FeedParser {

    // MARK: - Static internal methods

    static func parseRssData(_ data: Data, url: URL) -> Feed? {
        return parseRssData(data, url: url, lastRefreshDate: nil)
    }

    static func parseRssData(_ data: Data, cacheEntry: FeedCache.CacheEntry) -> Feed? {
        return parseRssData(data, url: cacheEntry.feedUrl, lastRefreshDate: cacheEntry.lastRefreshed)
    }

    // MARK: - Static private methods

    static func parseRssData(_ data: Data, url: URL, lastRefreshDate: Date?) -> Feed? {
        let parser = FeedKit.FeedParser(data: data)
        let result = parser.parse()

        switch result {
        case .failure:
            return nil
        case .success(let feed):
            guard let rssFeed = feed.rssFeed else {
                return nil
            }

            let mappedFeed = self.mapFeed(rssFeed: rssFeed, url: url, lastRefreshDate: lastRefreshDate ?? Date())
            return mappedFeed
        }
    }

    static private func mapFeed(rssFeed: RSSFeed, url: URL, lastRefreshDate: Date) -> Feed {
        var imageUrl: URL? = nil
        if let imageHref = rssFeed.iTunes?.iTunesImage?.attributes?.href {
            imageUrl = URL(string: imageHref)
        }

        let episodes = mapEpisodes(from: rssFeed.items ?? [])

        return Feed(episodes: episodes,
                    title: rssFeed.title ?? "Unnamed Feed",
                    imageUrl: imageUrl,
                    url: url,
                    lastRefreshDate: lastRefreshDate)
    }

    static private func mapEpisodes(from items: [RSSFeedItem]) -> [Episode] {
        var episodes = [Episode]()
        var seenEpisodes = Set<String>()

        for item in items {
            if let url = URL(string: item.enclosure?.attributes?.url ?? item.link ?? ""),
               let title = item.title,
               let date = item.pubDate,
               let duration = item.iTunes?.iTunesDuration,
               !seenEpisodes.contains(url.absoluteString) {
                let episode = Episode(url: url,
                                      title: title,
                                      description: item.description,
                                      duration: duration,
                                      date: date)
                seenEpisodes.insert(url.absoluteString)
                episodes.append(episode)
            }
        }

        return episodes
    }
}
