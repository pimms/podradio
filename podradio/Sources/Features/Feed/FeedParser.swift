import Foundation
import FeedKit
import CoreData

final class FeedParser {

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Internal methods

    func parseRssData(_ data: Data, url: URL) -> Feed? {
        return parseRssData(data, url: url, lastRefreshDate: nil)
    }

    // MARK: - Private methods

    private func parseRssData(_ data: Data, url: URL, lastRefreshDate: Date?) -> Feed? {
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

    private func mapFeed(rssFeed: RSSFeed, url: URL, lastRefreshDate: Date) -> Feed {
        var imageUrl: URL? = nil
        if let imageHref = rssFeed.iTunes?.iTunesImage?.attributes?.href {
            imageUrl = URL(string: imageHref)
        }

        let feed = Feed(context: context)
        feed.url = url
        feed.imageUrl = imageUrl
        feed.lastRefresh = lastRefreshDate
        feed.title = rssFeed.title ?? "Unnamed feed"

        let episodes = mapEpisodes(from: rssFeed.items ?? [])
        episodes.forEach({ $0.feed = feed })

        let seasons = buildSeasons(fromEpisodes: episodes)
        seasons.forEach({
            feed.addToSeasons($0)
            $0.feed = feed
        })

        return feed
    }

    private func mapEpisodes(from items: [RSSFeedItem]) -> [Episode] {
        var episodes = [Episode]()
        var seenUrls = Set<String>()

        for item in items {
            if let url = URL(string: item.enclosure?.attributes?.url ?? item.link ?? ""),
               let title = item.title,
               let date = item.pubDate,
               let duration = item.iTunes?.iTunesDuration,
               !seenUrls.contains(url.absoluteString) {

                let episode = Episode(context: context)
                episode.url = url
                episode.title = title
                episode.detailedDescription = item.description
                episode.duration = duration
                episode.publishDate = date

                seenUrls.insert(url.absoluteString)
                episodes.append(episode)
            }
        }

        return episodes
    }

    private func buildSeasons(fromEpisodes episodes: [Episode]) -> [Season] {
        // Build a map from publication year to episodes
        var yearMap: [Int: [Episode]] = [:]
        for episode in episodes {
            let year = episode.year
            if !yearMap.keys.contains(year) {
                yearMap[year] = []
            }
            yearMap[year]?.append(episode)
        }

        // Build Season-objects from the map
        var seasons: [Season] = []
        for (year, episodeSubset) in yearMap {
            let season = Season(context: context)
            season.name = "\(year)"
            season.uniqueId = UUID().uuidString
            episodeSubset.forEach({
                season.addToEpisodes($0)
                $0.season = season
            })
            seasons.append(season)
        }

        return seasons
    }
}
