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

    static func makeExampleFeed(context: NSManagedObjectContext) -> Feed {
        let feed = Feed(context: context)
        feed.title = "Example"
        feed.url = URL(string: "https://www.google.com/")!
        feed.imageUrl = URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b6/SIPI_Jelly_Beans_4.1.07.tiff/lossy-page1-256px-SIPI_Jelly_Beans_4.1.07.tiff.jpg")!

        let season = Season(context: context)
        season.name = "1999"
        season.uniqueId = "1999"
        feed.addToSeasons(season)

        for index in 0 ... 100 {
            let episode = Episode(context: context)
            episode.title = "Episode \(index+1)"
            episode.url = URL(string: "https://download.samplelib.com/mp3/sample-6s.mp3?foobar=\(index)")!
            episode.publishDate = Date().addingTimeInterval(-86400 * 7 * (TimeInterval(index) + 1.0))
            episode.detailedDescription = [String](repeating: "This is a nice episode.\n", count: 50).joined()
            episode.duration = 9
            feed.addToEpisodes(episode)
            season.addToEpisodes(episode)
        }

        return feed
    }
}
