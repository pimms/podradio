import Foundation
import FeedKit

final class FeedParser {

    // MARK: - Static internal methods

    static func parseRssData(_ data: Data, url: URL) -> Feed? {
        let parser = FeedKit.FeedParser(data: data)
        let result = parser.parse()

        switch result {
        case .failure:
            return nil
        case .success(let feed):
            guard let rssFeed = feed.rssFeed else {
                return nil
            }

            let mappedFeed = self.mapFeed(rssFeed: rssFeed, url: url)
            return mappedFeed
        }
    }

    // MARK: - Static private methods

    static private func mapFeed(rssFeed: RSSFeed, url: URL) -> Feed {
        // TODO: Download this image
        // let imageUrl = rssFeed.iTunes?.iTunesImage?.attributes?.href

        let episodes = mapEpisodes(from: rssFeed.items ?? [])

        return Feed(id: rssFeed.title ?? rssFeed.link ?? UUID().uuidString,
                    episodes: episodes,
                    title: rssFeed.title ?? "Unnamed Feed",
                    image: nil,
                    url: url)
    }

    static private func mapEpisodes(from items: [RSSFeedItem]) -> [Episode] {
        var episodes = [Episode]()
        var seenEpisodes = Set<String>()

        for item in items {
            if let url = URL(string: item.link ?? item.enclosure?.attributes?.url ?? ""),
               let title = item.title,
               let description = item.description,
               let date = item.pubDate,
               let duration = item.iTunes?.iTunesDuration,
               !seenEpisodes.contains(url.absoluteString) {
                let episode = Episode(url: url,
                                      title: title,
                                      description: description,
                                      duration: duration,
                                      date: date)
                seenEpisodes.insert(url.absoluteString)
                episodes.append(episode)
            }
        }

        return episodes
    }
}
