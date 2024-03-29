import SwiftUI

private let ABRAHAM = false

@main
struct podradioApp: App {
    let persistenceController: PersistenceController = {
        if ABRAHAM {
            let controller = PersistenceController(inMemory: true)

            let context = controller.mainContext
            let feed = DummyData.makeExampleFeed(context: context)
            try! context.save()

            return controller
        } else {
            return PersistenceController.shared
        }
    }()
    let player: Player
    let streamScheduleStore: StreamScheduleStore

    init() {
        player = Player()
        streamScheduleStore = StreamScheduleStore(persistenceController: persistenceController)
    }

    var body: some Scene {
        WindowGroup {
            FeedRootView(streamScheduleStore: streamScheduleStore)
                .environment(\.managedObjectContext, persistenceController.mainContext)
                .environmentObject(player)
        }
    }
}
