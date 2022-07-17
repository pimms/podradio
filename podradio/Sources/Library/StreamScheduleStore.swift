import Foundation
import SwiftUI
import CoreData

class StreamScheduleStore: ObservableObject {
    var isEmpty: Bool { feeds.isEmpty }
    @Published private(set) var feeds: [Feed] = []

    // I'm not sure if we can use CoreData objects as keys,
    // so we're just using the feed URL instead.
    private var map: [URL: StreamSchedule] = [:]
    private let fetcher: FeedFetchRequestExecutor

    init(persistenceController: PersistenceController) {
        fetcher = FeedFetchRequestExecutor(persistenceController: persistenceController)
        fetcher.onFetch = { [weak self] feeds in
            self?.rebuildIndex(feeds: feeds)
        }
        fetcher.beginFetching()
    }

    func streamSchedule(for feed: Feed) -> StreamSchedule {
        guard let streamSchedule = map[feed.url!] else {
            fatalError("Inconsistency: No stream schedule exists for feed '\(feed.url!)'")
        }

        return streamSchedule
    }

    private func rebuildIndex(feeds: [Feed]) {
        // First, drop any feeds that have been removed
        var feedsToDrop: [URL] = []
        for key in map.keys {
            if feeds.contains(where: { $0.isSameFeed(as: key) }) {
                feedsToDrop.append(key)
            }
        }
        feedsToDrop.forEach({ _ = map.removeValue(forKey: $0) })

        // Identify all new feeds and add them to the map
        for feed in feeds {
            if map[feed.url!] == nil {
                let streamSchedule = StreamSchedule(feed: feed)
                map[feed.url!] = streamSchedule
            }
        }

        // Notify any listeners of new data
        self.feeds = feeds
    }
}

private class FeedFetchRequestExecutor: NSObject, NSFetchedResultsControllerDelegate {
    var onFetch: (([Feed]) -> Void)?

    private let persistenceController: PersistenceController
    private let fetchedResultsController: NSFetchedResultsController<Feed>

    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController

        let fetchRequest = Feed.fetchRequest()
        fetchRequest.sortDescriptors = [.init(key: #keyPath(Feed.title), ascending: true)]
        fetchRequest.includesSubentities = true

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: persistenceController.container.viewContext,
            sectionNameKeyPath: "title",
            cacheName: nil)
        super.init()

        fetchedResultsController.delegate = self
    }

    func beginFetching() {
        try! fetchedResultsController.performFetch()
        onFetch?(fetchedResultsController.fetchedObjects ?? [])
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let feeds = fetchedResultsController.fetchedObjects ?? []
        onFetch?(feeds)
    }
}
