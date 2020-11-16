import Foundation

class FeedCache {
    fileprivate struct CodableCacheEntry {

    }

    struct CacheEntry: Codable {
        fileprivate let feedUrlString: String
        fileprivate let feedContentFileName: String
        let lastRefreshed: Date

        var feedUrl: URL { URL(string: feedUrlString)! }
        var feedFilePath: URL { FeedCache.feedContentPath(fileName: feedContentFileName) }
        var feedContent: Data? { try? Data(contentsOf: feedFilePath) }

        init(feedUrl: URL, feedContentFileName: String, lastRefreshed: Date) {
            self.feedUrlString = feedUrl.absoluteString
            self.feedContentFileName = feedContentFileName
            self.lastRefreshed = lastRefreshed
        }

        private init(feedUrlString: String, feedContentFileName: String, lastRefreshed: Date) {
            self.feedUrlString = feedUrlString
            self.feedContentFileName = feedContentFileName
            self.lastRefreshed = lastRefreshed
        }
    }

    private static var indexFilePath: URL {
        let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let url = URL(fileURLWithPath: docDir)
        let filePath = url.appendingPathComponent("cacheIndex.plist")
        return filePath
    }

    private static func feedContentPath(fileName: String) -> URL {
        let cacheDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let url = URL(fileURLWithPath: cacheDir)
        return url.appendingPathComponent(fileName)
    }

    // MARK: - Internal properties

    var cache: [CacheEntry]

    // MARK: - Setup

    init() {
        cache = []
        loadIndexFile()
    }

    // MARK: - Internal methods

    func cacheFeed(_ url: URL, feedContent: Data) {
        let fileName = MD5(string: url.absoluteString)
        let entry = CacheEntry(feedUrl: url, feedContentFileName: fileName, lastRefreshed: Date())

        do {
            try feedContent.write(to: entry.feedFilePath)

            cache.removeAll(where: { $0.feedUrl == url })
            cache.append(entry)
            try persistIndexFile()
        } catch {
            print("Failed to cache feed: \(error)")
        }
    }

    func remove(_ entry: CacheEntry) {
        do {
            cache.removeAll(where: { $0.feedUrl == entry.feedUrl })
            try persistIndexFile()
        } catch {
            print("Failed to persist index file: \(error)")
        }
    }

    // MARK: - Private methods

    private func loadIndexFile() {
        if let data = try? Data(contentsOf: Self.indexFilePath) {
            let decoder = PropertyListDecoder()
            cache = (try? decoder.decode([CacheEntry].self, from: data)) ?? []
        }
    }

    private func persistIndexFile() throws {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        let data = try encoder.encode(cache)
        try data.write(to: Self.indexFilePath)
    }
}
