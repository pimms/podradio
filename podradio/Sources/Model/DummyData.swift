import Foundation
import CoreData

struct DummyData {
    @discardableResult
    static func makeFeed(context: NSManagedObjectContext, title: String, episodeCount: Int) -> Feed {
        let feed = Feed(context: context)
        feed.title = title
        feed.url = URL(string: "https://\(title).com")!
        feed.imageUrl = URL(string: "https://thumbs.dreamstime.com/b/owls-portrait-owl-eyes-close-up-image-owls-portrait-owl-eyes-image-136855731.jpg")

        for index in 0 ... episodeCount {
            let episode = Episode(context: context)
            episode.title = "Episode \(index+1)"
            episode.url = URL(string: "https://\(title).com/episode/\(index)")
            episode.detailedDescription = "Episode \(index+1), this is where it gets real yo"
            episode.publishDate = Date().addingTimeInterval(-86400 * 3 * Double(index))
            episode.duration = 3937
            feed.addToEpisodes(episode)
        }

        return feed
    }
}
