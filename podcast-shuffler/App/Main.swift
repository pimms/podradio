import SwiftUI
import AVFoundation

@main
struct Main: App {
    @StateObject private var feedStore = FeedStore()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .modifier(SystemServices())
                .onAppear(perform: onAppear)
        }
    }

    private func onAppear() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[EpisodePlayer] AVAudioSession failure: \(error)")
        }
    }
}
