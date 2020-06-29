import Foundation
import FeedKit

class FeedProvider {
    private enum FeedError: Error {
        case invalidFeed
    }

    // MARK: - Internal properties

    var persistentFeedUrls: [URL] { feedIndex.feedIndex }

    // MARK: - Private properties

    private let httpClient: HttpClient
    private let feedIndex: FeedIndexList

    init(httpClient: HttpClient = HttpClient()) {
        self.httpClient = httpClient
        self.feedIndex = FeedIndexList()
    }

    // MARK: - Internal methods

    func downloadFeed(at url: URL, handler: @escaping (Result<Feed, Error>) -> Void) {
        httpClient.get(url, handler: { [weak self] result in
            switch result {
            case .success(let data):
                guard let data = data,
                      let feed = self?.parseRssData(data, url: url) else {
                    handler(.failure(FeedError.invalidFeed))
                    return
                }
                handler(.success(feed))

            case .failure:
                handler(.failure(FeedError.invalidFeed))
            }
        })
    }

    func saveLocalReference(to url: URL) {
        feedIndex.persistUrl(url)
    }

    // MARK: - Private methods

    private func parseRssData(_ data: Data, url: URL) -> Feed? {
        let parser = FeedParser(data: data)
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

    private func mapFeed(rssFeed: RSSFeed, url: URL) -> Feed {
        // TODO: Download this image
        // let imageUrl = rssFeed.iTunes?.iTunesImage?.attributes?.href

        let episodes = mapEpisodes(from: rssFeed.items ?? [])

        return Feed(id: rssFeed.title ?? rssFeed.link ?? UUID().uuidString,
                    episodes: episodes,
                    title: rssFeed.title ?? "Unnamed Feed",
                    image: nil,
                    url: url)
    }

    private func mapEpisodes(from items: [RSSFeedItem]) -> [Episode] {
        var episodes = [Episode]()
        for item in items {
            if let url = URL(string: item.link ?? item.enclosure?.attributes?.url ?? ""),
               let title = item.title,
               let description = item.description,
               let date = item.pubDate {
                let episode = Episode(url: url, title: title, description: description, date: date)
                episodes.append(episode)
            }
        }

        return episodes
    }
}
