import SwiftUI

@main
struct podradioApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            NavigationView {
                FeedRootView()
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
