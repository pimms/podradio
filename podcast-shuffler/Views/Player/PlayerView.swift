import SwiftUI

struct PlayerRootView: View {
    var feed: Feed

    var body: some View {
        VStack {
            Spacer()
            EpisodeViewLink(feed: feed)
        }
        .navigationTitle(feed.title)
    }
}

private struct EpisodeViewLink: View {
    var feed: Feed

    var body: some View {
        HStack {
            Spacer()
            NavigationLink(destination: EpisodeRootView(episodes: feed.episodes)) {
                Text("See all episodes")
            }
            Spacer()
        }
    }
}

// MARK: - Previews

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PlayerRootView(feed: Feed.testData[0])
        }
    }
}
