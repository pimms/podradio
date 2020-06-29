import Foundation

class FeedIndexList {
    private static var fileUrl: URL {
        let cacheDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        let url = URL(fileURLWithPath: cacheDir)
        return url.appendingPathComponent("feedIndexList.plist")
    }

    var feedIndex: [URL]

    init() {
        feedIndex = []
        loadIndexFile()
    }

    func persistUrl(_ url: URL) {
        guard !feedIndex.contains(url) else { return }

        do {
            feedIndex.append(url)
            let stringArray = feedIndex.map { $0.absoluteString }

            let encoder = PropertyListEncoder()
            let data = try encoder.encode(stringArray)
            try data.write(to: Self.fileUrl)
        } catch {
            print("Failed to persist feed index: \(error)")
        }
    }

    private func loadIndexFile() {
        if let data = try? Data(contentsOf: Self.fileUrl) {
            let decoder = PropertyListDecoder()
            let strings = (try? decoder.decode([String].self, from: data)) ?? []
            self.feedIndex = strings.compactMap { URL(string: $0) }
        }
    }
}
