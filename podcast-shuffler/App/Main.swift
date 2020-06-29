import SwiftUI

@main
struct Main: App {
    @StateObject private var feedStore = FeedStore()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .modifier(SystemServices())
        }
    }
}
