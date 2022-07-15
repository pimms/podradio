import Foundation

extension Feed {
    func isSameFeed(as other: Feed) -> Bool {
        return self.url == other.url
    }

    func isSameFeed(as url: URL) -> Bool {
        return self.url == url
    }
}
