import Foundation
import SwiftUI
import CoreData
import struct Kingfisher.KFImage

struct PlayerRootView: View {
    let feed: Feed
    @EnvironmentObject var player: Player

    var body: some View {
        VStack {
            FeedImageView(feed: feed)
            Text(feed.title!).font(.title)
            Text(player.atom?.title ?? "").font(.headline)

            ScrollView {
                // TODO: Make it so that this text doesn't offset the image above
                Text(player.atom?.description ?? "")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            PlayControlSheet(feed: feed)
        }.onAppear(perform: {
            self.player.configure(with: feed)
        })
    }
}

private struct FeedImageView: View {
    let feed: Feed

    var body: some View {
        KFImage(feed.imageUrl)
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .cornerRadius(30)
            .shadow(color: .gray, radius: 20)
            .padding(30)
    }
}

private struct PlayControlSheet: View {
    let feed: Feed

    var body: some View {
        VStack {
            Spacer().frame(width: 0, height: 20)
            VStack {
                HStack {
                    Spacer()
                    AirPlayButton()
                    Spacer()
                    PlayButton()
                    Spacer()
                    FilterButton(feed: feed)
                    Spacer()
                }
                ProgressBar()
            }
            Spacer().frame(width: 0, height: 20)
        }
        .background(
            RoundedCorners(color: .tertiaryLabel, tl: 20, tr: 20, bl: 0, br: 0)
                .ignoresSafeArea(.all, edges: .bottom)
        )
    }
}

private struct ProgressBar: View {
    @EnvironmentObject var player: Player

    var body: some View {
        ProgressView(value: player.currentTime, total: player.atom?.duration ?? 1)
            .tint(.secondarySystemBackground)
            .padding(.horizontal, 20)
            .padding(.top, 5)
    }
}

private struct PlayButton: View {
    @EnvironmentObject var player: Player
    @State private var rotation: Double = 0

    var isLoading: Bool {
        switch player.playerState {
        case .playing,
             .paused,
             .readyToPlay,
             .none:
            return false
        case .episodeTransition,
             .waitingToPlay:
            return true
        }
    }

    var playerIconSystemName: String {
        switch player.playerState {
        case .playing:
            return "pause.fill"
        case .paused, .readyToPlay, .none:
            return "play.fill"
        case .episodeTransition, .waitingToPlay:
            // never shown
            return "pause.fill"
        }
    }

    var body: some View {
        return Button(action: playButtonTapped, label: {
            if isLoading {
                LoadingView()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 35, height: 35, alignment: .center)
            } else {
                Image(systemName: playerIconSystemName)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 35, height: 35, alignment: .center)
            }
        })
        .foregroundColor(.secondarySystemBackground)
    }

    private func playButtonTapped() {
        print("Play button tapped")
        player.togglePlay()
    }
}

private struct LoadingView: View {
    @State var isVisible: Bool = false

    var body: some View {
        Image(systemName: "circle.dotted")
            .resizable()
            .rotationEffect(.degrees(isVisible ? 360 : 0))
            .animation(Animation.linear(duration: 1).repeatForever())
            .onAppear {
                isVisible = true
            }
    }
}

private struct FilterButton: View {
    @StateObject var feed: Feed
    @State private var isPresentingFilter: Bool = false

    /// We need a `@StateObject` on the `FeedFilter` to get updates
    /// when the filter changes.
    private struct FilterBindingView: View {
        @StateObject var filter: SeasonFilter
        var body: some View {
            return Image(systemName: "line.horizontal.3.decrease.circle.fill")
                .tint(Color(UIColor.systemBlue))
        }
    }

    private var image: some View {
        Group {
            if let filter = feed.filter, let seasons = filter.includedSeasons, !seasons.isEmpty {
                FilterBindingView(filter: filter)
            } else {
                Image(systemName: "line.horizontal.3.decrease.circle")
                    .tint(.secondarySystemBackground)
            }
        }
    }

    var body: some View {
        return Button(action: onTap) {
            image.frame(width: 24, height: 24)
        }
        .sheet(isPresented: $isPresentingFilter, onDismiss: nil) {
            FilterRootView(feed: feed)
        }
    }

    private func onTap() {
        isPresentingFilter.toggle()
    }
}

struct PlayerRootView_Preview: PreviewProvider {
    private static var persistenceController = PersistenceController.preview
    private static var feed: Feed {
        let moc = persistenceController.container.viewContext
        return DummyData.makeExampleFeed(context: moc)
    }

    private static var mockPlayer: Player {
        let player = Player(dummyPlayer: true)
        player.configure(with: feed)
        return player
    }

    static var previews: some View {
        PlayerRootView(feed: feed)
            .environmentObject(mockPlayer)
    }
}
