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
            PlayButton(state: player.state, onTap: onPlayButtonTap)
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

    private func onPlayButtonTap() {
        switch player.state {
        case .playing:
            player.pause()
        case .paused:
            player.play()
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
    var state: EpisodePlayer.State
    var onTap: (() -> Void)

    var body: some View {
        Button(action: onTap, label: {
            ZStack {
                Image(systemName: sfButtonName)
                    .resizable()
                    .foregroundColor(Color(UIColor.label))
                    .frame(width: 40, height: 40, alignment: .center)
                Circle()
                    .stroke(Color.primary, lineWidth: 4)
                    .frame(width: 80, height: 80, alignment: .center)
                    .foregroundColor(.clear)
            }
        })
    }

    private var sfButtonName: String {
        switch state {
        case .playing:
            return "pause.fill"
        case .paused:
            return "play.fill"
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

        PlayButton(state: .paused, onTap: {})
            .previewLayout(.sizeThatFits)
            .padding()
        PlayButton(state: .playing, onTap: {})
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
