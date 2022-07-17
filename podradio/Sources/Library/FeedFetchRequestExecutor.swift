import Foundation
import CoreData

class FeedFetchRequestExecutor: NSObject, NSFetchedResultsControllerDelegate {
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
            managedObjectContext: persistenceController.mainContext,
            sectionNameKeyPath: "title",
            cacheName: nil)
        super.init()

        fetchedResultsController.delegate = self
    }

    // MARK: - Internal methods

    func beginFetching() {
        try! fetchedResultsController.performFetch()
        notifyListener()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        notifyListener()
    }

    // MARK: - Private methods

    private func notifyListener() {
        guard let feeds = fetchedResultsController.fetchedObjects else { return }
        guard let onFetch else { return }
        onFetch(feeds)
    }
}
