import SwiftUI

struct FeedRootView: View {

    private static let log = Log(Self.self)

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Feed.title, ascending: true)],
        animation: .default)
    private var feeds: FetchedResults<Feed>

    var body: some View {
        Group {
            if feeds.isEmpty {
                NoFeedsView()
            } else {
                List() {
                    ForEach(feeds) { feed in
                        NavigationLink(destination: {
                            PlayerRootView(feed: feed)
                        }, label: {
                            FeedCell(feed: feed)
                        })
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("frontpage.title")
        .navigationBarItems(leading: NavBarButton(), trailing: AddFeedButton())
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
        Group {
            NavigationView {
                FeedRootView()
                    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                    .environmentObject(mockPlayer)
            }
        }
    }
}
