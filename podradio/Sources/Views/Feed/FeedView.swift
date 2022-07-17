import SwiftUI

struct FeedRootView: View {
    private static let log = Log(Self.self)
    @ObservedObject var streamScheduleStore: StreamScheduleStore
    @State private var path: [Feed] = []

    var body: some View {
        Group {
            if streamScheduleStore.isEmpty {
                NoFeedsView()
            } else {
                NavigationStack(path: $path) {
                    List() {
                        ForEach(streamScheduleStore.feeds) { feed in
                            NavigationLink(value: feed) {
                                FeedCell(feed: feed)
                            }
                        }
                    }
                    .navigationTitle("frontpage.title")
                    .navigationBarItems(leading: NavBarButton(), trailing: AddFeedButton())
                    .navigationDestination(for: Feed.self) { feed in
                        PlayerRootView(streamSchedule: streamScheduleStore.streamSchedule(for: feed))
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .onAppear {
            loadInitialFeed()
        }
    }

    private func loadInitialFeed() {
        guard let url = DefaultFeedStore.defaultFeedUrl() else { return }
        guard let feed = streamScheduleStore.feeds.first(where: { $0.url == url }) else { return }
        path = [feed]
    }
}

private struct FeedCell: View {
    @EnvironmentObject var player: Player
    let feed: Feed

    var body: some View {
        HStack {
            ListFeedImageView(imageUrl: feed.imageUrl)

            VStack {
                HStack {
                    if player.playerState == .playing && player.feed == feed {
                        Image(systemName: "play.circle.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    Text(feed.title!)
                        .foregroundColor(.primary)
                    Spacer()
                }
            }
        }
    }
}

private struct NavBarButton: View {
    var body: some View {
        HStack {
            SettingsButton()
            HelpButton()
        }
    }
}

private struct HelpButton: View {
    @State var isPresenting = false

    var body: some View {
        Button(action: {
            self.isPresenting = true
        }, label: {
            Image(systemName: "questionmark.circle")
        })
        .sheet(isPresented: $isPresenting, content: {
            HelpRootView()
        })
    }
}

private struct SettingsButton: View {
    @State var isPresenting = false

    var body: some View {
        Button(action: {
            self.isPresenting = true
        }, label: {
            Image(systemName: "gear")
        })
        .sheet(isPresented: $isPresenting) {
            SettingsRootView()
        }
    }
}

private struct AddFeedButton: View {
    @State var isPresenting = false

    var body: some View {
        Button(action: {
            self.isPresenting = true
        }, label: {
            Text("frontpage.addFeed")
        })
        .sheet(isPresented: $isPresenting) {
            AddFeedView(presenting: self.$isPresenting)
        }
    }
}

// MARK: - Previews

struct FeedRootView_Previews: PreviewProvider {
    private static var mockPlayer: Player { Player(dummyPlayer: true) }

    static var previews: some View {
        FeedRootView(streamScheduleStore: DummyData.streamScheduleStore)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(mockPlayer)
    }
}
