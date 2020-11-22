import SwiftUI

struct PlayerRootView: View {
    @StateObject var player: EpisodePlayer
    var feed: Feed

    init(feed: Feed) {
        self.feed = feed

        let player: EpisodePlayer
        if let currentPlayer = EpisodePlayer.current,
           currentPlayer.feed?.id == feed.id {
            player = currentPlayer
        } else {
            player = EpisodePlayer()
        }
        self._player = StateObject(wrappedValue: player)
    }

    var body: some View {
        VStack {
            Spacer()
            NowPlayingLabel(player: player)
                .padding()
            PlayButton(player: player, feed: feed)
            Spacer()
            EpisodeViewLink(feed: feed)
        }
        .navigationTitle(feed.title)
        .onAppear {
            if player.state != .playing,
               let picker = EpisodePicker(feed: feed) {
                player.configure(with: picker)
            }
        }
    }
}

private struct NowPlayingLabel: View {
    @StateObject var player: EpisodePlayer

    var body: some View {
        VStack {
            Text("\(player.currentEpisode?.title ?? "title")")
                .font(.headline)
            Text("\(player.currentEpisode?.description ?? "description")")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

private struct PlayButton: View {
    @StateObject var player: EpisodePlayer
    var feed: Feed

    var body: some View {
        Button(action: onTap, label: {
            Text(player.state == .playing ? "Pause" : "Play")
                .fontWeight(.bold)
                .font(.title)
                .foregroundColor(.primary)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.primary, lineWidth: 5)
                )
        })
    }

    private func onTap() {
        switch player.state {
        case .playing:
            player.pause()
        case .paused:
            player.play()
        }
    }
}

private struct EpisodeViewLink: View {
    var feed: Feed

    var body: some View {
        HStack {
            Spacer()
            NavigationLink(destination: EpisodeRootView(feed: feed)) {
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
        .preferredColorScheme(.dark)
    }
}
