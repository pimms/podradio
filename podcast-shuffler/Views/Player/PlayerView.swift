import SwiftUI
import struct Kingfisher.KFImage

struct PlayerRootView: View {
    let feed: Feed

    var body: some View {
        ZStack {
            BackdropImageView(imageUrl: feed.imageUrl)
            PlayerContentView(feed: feed)
        }
        .navigationTitle(feed.title)
    }
}

private struct BackdropImageView: View {
    var imageUrl: URL?

    var body: some View {
        GeometryReader { metrics in
            VStack {
                ZStack {
                    KFImage(imageUrl)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                    Rectangle()
                        .foregroundColor(.clear)
                        .background(LinearGradient(gradient: Gradient(colors: [Color.systemBackground.opacity(0.85),
                                                                               Color.systemBackground.opacity(1)]),
                                                   startPoint: .top, endPoint: .bottom))
                }.frame(width: metrics.size.width, height: metrics.size.height * 0.9)
                Spacer()
            }.edgesIgnoringSafeArea(.all)
        }
    }
}

private struct PlayerContentView: View {
    static let log = Log(Self.self)

    @StateObject var player: EpisodePlayer
    var feed: Feed

    @AppStorage(StorageKey.useBingeEpisodePicker.rawValue)
    private var useBingePicker = false
    @State private var isPresentingFilter = false
    @State private var hasCustomFilter = false

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
            Spacer()

            ZStack {
                PlayButton(state: player.state, onTap: onPlayButtonTap)
                    .padding(.bottom, 20)

                HStack {
                    FilterButton(isActive: hasCustomFilter, onTap: { isPresentingFilter.toggle() })
                        .frame(width: 24, height: 24)
                        .padding(.leading, 20)
                        .sheet(isPresented: $isPresentingFilter) {
                            FilterRootView(feed: feed)
                                .onDisappear(perform: reconfigure)
                        }
                    Spacer()

                    if !ProcessInfo.processInfo.isMacCatalystApp && !ProcessInfo.processInfo.isiOSAppOnMac {
                        AirPlayButton()
                            .frame(width: 40, height: 40)
                            .padding(.trailing, 20)
                    }
                }
            }
            ProgressBarView(player: player)
                .frame(maxHeight: 40)
                .padding()
                .padding(.bottom, 20)
        }
        .onAppear(perform: onAppear)
    }

    private func onAppear() {
        if player.state != .playing {
            reconfigure()
        }
    }

    private func reconfigure() {
        Self.log.debug("Reconfiguring")
        let picker = episodePicker(for: feed)
        let wasPlaying = player.state == .playing
        player.configure(with: picker)
        if wasPlaying {
            Self.log.debug("Was playing before reconf, resuming playback")
            player.play()
        }

        hasCustomFilter = !(FilterStore.shared.filter(for: feed) is DefaultFilter)
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
            Text("\(player.currentEpisode?.title ?? "")")
                .font(.headline)
            Text(formattedDateString)
                .font(.caption)
                .foregroundColor(.secondary)
            ScrollView {
                Text("\(player.currentEpisode?.description ?? "")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var formattedDateString: String {
        let date = player.currentEpisode?.date ?? Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

private struct FilterButton: View {
    let isActive: Bool
    var onTap: (() -> Void)

    var body: some View {
        Button(action: onTap) {
            Image(systemName: "line.horizontal.3.decrease.circle")
                .resizable()
                .foregroundColor(isActive ? .accentColor : .primary)
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

// MARK: - Previews

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerRootView(feed: Feed.testData[0])

        PlayButton(state: .paused, onTap: {})
            .previewLayout(.sizeThatFits)
            .padding()
        PlayButton(state: .playing, onTap: {})
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
