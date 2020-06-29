import Foundation
import FeedKit

class FeedProvider {
    private enum FeedError: Error {
        case invalidFeed
    }

    func downloadFeed(at url: URL, handler: @escaping (Result<Feed, Error>) -> Void) {
        let parser = FeedParser(URL: url)
        parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                handler(.failure(FeedError.invalidFeed))
            case .success(let feed):
                guard let rssFeed = feed.rssFeed else {
                    handler(.failure(FeedError.invalidFeed))
                    return
                }

                let mappedFeed = self.mapFeed(rssFeed: rssFeed)
                handler(.success(mappedFeed))
            }
        }
    }

    private func mapFeed(rssFeed: RSSFeed) -> Feed {
        // TODO: Download this image
        // let imageUrl = rssFeed.iTunes?.iTunesImage?.attributes?.href

        let episodes = mapEpisodes(from: rssFeed.items ?? [])

        return Feed(id: rssFeed.title ?? rssFeed.link ?? UUID().uuidString,
                    episodes: episodes,
                    title: rssFeed.title ?? "Unnamed Feed",
                    image: nil)
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
