import Foundation

struct DefaultFeedStore {
    private init() {}

    private static let key = "defaultFeedStore/defaultFeed"

    static func setDefaultFeed(_ feed: Feed) {
        UserDefaults.standard.set(feed.url!.absoluteString, forKey: key)
    }

    static func defaultFeedUrl() -> URL? {
        guard let string = UserDefaults.standard.value(forKey: key) as? String else {
            return nil
        }
        
        return URL(string: string)
    }
}
