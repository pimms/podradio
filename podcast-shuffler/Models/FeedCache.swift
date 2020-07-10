import Foundation

class FeedCache {
    struct CacheEntry: Codable {
        fileprivate let feedUrlString: String
        fileprivate let filePathString: String
        let lastRefreshed: Date

        var feedUrl: URL { URL(string: feedUrlString)! }
        var filePath: URL { URL(string: filePathString)! }

        init(feedUrl: URL, filePath: URL, lastRefreshed: Date) {
            self.feedUrlString = feedUrl.absoluteString
            self.filePathString = filePath.absoluteString
            self.lastRefreshed = lastRefreshed
        }
    }

    private static var indexFilePath: URL {
        cachePath(fileName: "feedIndexList.plist")
    }

    private static func cachePath(fileName: String) -> URL {
        let cacheDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
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
        let feedFilePath = Self.cachePath(fileName: fileName)
        let entry = CacheEntry(feedUrl: url, filePath: feedFilePath, lastRefreshed: Date())

        do {
            try feedContent.write(to: feedFilePath)

            cache.removeAll(where: { $0.feedUrl == url })
            cache.append(entry)
            let encoder = PropertyListEncoder()
            let data = try encoder.encode(cache)
            try data.write(to: Self.indexFilePath)
        } catch {
            print("Failed to persist feed index: \(error)")
        }
    }

    // MARK: - Private methods

    private func loadIndexFile() {
        if let data = try? Data(contentsOf: Self.indexFilePath) {
            let decoder = PropertyListDecoder()
            cache = (try? decoder.decode([CacheEntry].self, from: data)) ?? []
        }
    }
}
