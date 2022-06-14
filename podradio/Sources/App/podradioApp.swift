import SwiftUI

@main
struct podradioApp: App {
    let persistenceController = PersistenceController.shared
    let player = Player()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                FeedRootView()
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(player)
        }
    }
}
