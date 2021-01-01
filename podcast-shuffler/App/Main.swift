import SwiftUI
import AVFoundation

@main
struct Main: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
                    .modifier(SystemServices())
        }
    }
}
