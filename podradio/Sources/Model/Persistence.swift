import CoreData

struct PersistenceController {

    // MARK: - Static

    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.mainContext

        DummyData.makeFeed(context: viewContext, title: "feeda", episodeCount: 30)
        DummyData.makeFeed(context: viewContext, title: "feedb", episodeCount: 5)
        DummyData.makeFeed(context: viewContext, title: "feedc", episodeCount: 9)

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    // MARK: - Internal properties

    var mainContext: NSManagedObjectContext { container.viewContext }

    // MARK: - Private properties

    private let container: NSPersistentCloudKitContainer

    // MARK: - Setup

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "podradio")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
    }
}
