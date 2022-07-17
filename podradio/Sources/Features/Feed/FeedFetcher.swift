import Foundation
import CoreData

class FeedFetcher {
    private let managedObjectContext: NSManagedObjectContext
    private let httpClient = HttpClient()
    private lazy var log = Log(self)

    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }

    // MARK: - Internal methods

    func fetchFeed(from url: URL, completion: @escaping (Bool) -> Void) {
        guard let url = url.validUrl else {
            completion(false)
            return
        }

        if let itunesId = ITunesId(url: url) {
            let linkExtractor = ITunesLinkExtractor(httpClient: httpClient)
            linkExtractor.extractLink(forId: itunesId) { result in
                switch result {
                case .success(let rssUrl):
                    self.log.debug("Fetched RSS URL (\(rssUrl)) from iTunes URL \(url)")
                    self.addRssFeed(from: rssUrl, completion: completion)
                case .failure:
                    self.log.error("Failed to extract RSS URL from iTunes URL: \(url)")
                    completion(false)
                }
            }
        } else {
            addRssFeed(from: url, completion: completion)
        }
    }

    // MARK: - Private methods

    private func addRssFeed(from url: URL, completion: @escaping (Bool) -> Void) {
        guard let url = url.validUrl else {
            completion(false)
            return
        }

        httpClient.get(url) { response in
            switch response {
            case .success(let data):
                self.log.debug("Successfully fetched RSS feed")
                let successfullyAdded = self.handleFeedData(url: url, data: data)
                DispatchQueue.main.async {
                    completion(successfullyAdded)
                }
            case .failure(let error):
                self.log.error("Failed to fetch RSS feed: \(error)")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }

    private func handleFeedData(url: URL, data: Data?) -> Bool {
        guard let data = data else { return false }

        return managedObjectContext.performAndWait {
            let existingFeed = localFeed(withUrl: url)

            let parser = FeedParser(context: managedObjectContext)
            guard let feed = parser.parseRssData(data, url: url) else {
                log.error("Failed to parse RSS feed \(url)")
                return false
            }

            do {
                if let existingFeed = existingFeed {
                    log.debug("Replacing previously fetched feed (\(existingFeed.objectID))")
                    if let existingFilter = existingFeed.filter {
                        let previousSeasons = existingFilter.includedSeasons ?? []
                        let seasons = feed.seasons!.allObjects.compactMap({ $0 as? Season })
                        let includedSeasons = previousSeasons.filter({ seasonId in
                            seasons.contains(where: { season in
                                season.uniqueId == seasonId
                            })
                        })

                        if !includedSeasons.isEmpty {
                            let newFilter = SeasonFilter(context: managedObjectContext)
                            newFilter.feed = feed
                            feed.filter = newFilter
                            newFilter.includedSeasons = includedSeasons
                        }
                    }

                    managedObjectContext.delete(existingFeed)
                }

                try managedObjectContext.save()
                log.debug("Successfully added feed \(url) with \(feed.episodes?.count ?? 0) episodes")
                return true
            } catch {
                managedObjectContext.rollback()
                return false
            }
        }
    }

    private func localFeed(withUrl url: URL) -> Feed? {
        let request = Feed.fetchRequest()
        request.predicate = NSPredicate(format: "url == %@", url.absoluteString)

        do {
            let result = try managedObjectContext.fetch(request)
            return result.first
        } catch {
            log.error("Failed to execute NSFetchRequest: \(error)")
            return nil
        }
}
}

private extension URL {
    /// If specifying a URL on the form 'example.com/path', the entire URL is considered the path, and
    /// this makes `url.host == nil` and `url.path == "example.com/path`. This doesn't
    /// really matter, but when forcefully adding `https` later, the URL becomes `https:example.com/path`.
    /// THIS IS ALSO FINE, but when displaying the URL it looks unfamiliar, and when exporting it becomes useless.
    ///
    /// Therefore, dirtily add `https://` prefix.
    var validUrl: URL? {
        if host == nil && scheme == nil {
            guard let httpsUrl = URL(string: "https://\(absoluteString)") else { return nil }
            return httpsUrl
        }

        if self.scheme == "https" {
            return self
        }

        var comps = URLComponents(url: self, resolvingAgainstBaseURL: true)
        comps?.scheme = "https"
        return comps?.url
    }
}
