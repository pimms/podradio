import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        func makeFeed(title: String, episodeCount: Int) {
            let feed = Feed(context: viewContext)
            feed.title = title
            feed.url = URL(string: "https://\(title).com")!
            feed.imageUrl = URL(string: "https://thumbs.dreamstime.com/b/owls-portrait-owl-eyes-close-up-image-owls-portrait-owl-eyes-image-136855731.jpg")

            for index in 0 ... episodeCount {
                let episode = Episode(context: viewContext)
                episode.title = "Episode \(index+1)"
                episode.url = URL(string: "https://\(title).com/episode/\(index)")
                episode.detailedDescription = "Episode \(index+1), this is where it gets real yo"
                episode.publishDate = Date().addingTimeInterval(-86400 * 3 * Double(index))
                episode.duration = 3937
                feed.addToEpisodes(episode)
            }
        }

        makeFeed(title: "feeda", episodeCount: 100)
        makeFeed(title: "feedb", episodeCount: 5)
        makeFeed(title: "feedc", episodeCount: 1538)

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "podradio")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
