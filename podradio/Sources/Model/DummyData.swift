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

    static func makeAbraham(context: NSManagedObjectContext) -> Feed {
        let feed = Feed(context: context)
        feed.title = "Abraham Loop"
        feed.url = URL(string: "https://www.google.com/")!
        feed.imageUrl = URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Abraham_Lincoln_by_Byers%2C_1858_-_crop.jpg/340px-Abraham_Lincoln_by_Byers%2C_1858_-_crop.jpg")!

        let season = Season(context: context)
        season.name = "1863"
        season.uniqueId = "1863"
        feed.addToSeasons(season)

        for index in 0 ... 2 {
            let episode = Episode(context: context)
            episode.title = "Episode 1"
            episode.url = URL(string: "https://www2.cs.uic.edu/~i101/SoundFiles/gettysburg10.wav")!
            episode.publishDate = Date().addingTimeInterval(-86400 * 7 * (TimeInterval(index) + 1.0))
            episode.duration = 10
            feed.addToEpisodes(episode)
            season.addToEpisodes(episode)
        }

        return feed
    }
}
