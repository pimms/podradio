import SwiftUI
import struct Kingfisher.KFImage

struct FeedRootView: View {
    private let feedStore: FeedStore

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @AppStorage("selectedFeedId") private var selectedId: Feed.Id?

    private static let log = Log(Self.self)

    init(feedStore: FeedStore) {
        self.feedStore = feedStore
    }

    private var navigationLink: NavigationLink<EmptyView,PlayerRootView>? {
        guard let selectedId = selectedId,
              let selectedFeed = feedStore.feeds.first(where: { $0.id == selectedId }) else {
            return nil
        }

        return NavigationLink(
            destination: PlayerRootView(feed: selectedFeed),
            tag: selectedId,
            selection: $selectedId) {
            EmptyView()
        }
    }

    var body: some View {
        Group {
            let feeds = feedStore.feeds
            if feeds.isEmpty && !ProcessInfo.isiPad {
                NoFeedsView()
            } else {
                ZStack {
                    navigationLink
                    List() {
                        ForEach(feedStore.feeds) { feed in
                            Button(action: { self.selectedId = feed.id }) {
                                FeedCell(feed: feed)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
        }
        .navigationTitle("Feeds")
        .navigationBarItems(leading: NavBarButton(), trailing: AddFeedButton())
        .onAppear(perform: {
            let exists = feedStore.feeds.firstIndex(where: { $0.id == selectedId }) != nil
            if !exists, horizontalSizeClass == .regular {
                selectedId = feedStore.feeds.first?.id
            }
        })
    }
}

private struct FeedCell: View {
    let feed: Feed

    var body: some View {
        HStack {
            FeedImageView(imageUrl: feed.imageUrl)

            VStack {
                HStack {
                    Text(feed.title)
                        .foregroundColor(.primary)
                    Spacer()
                }
            }
        }
    }
}

struct FeedImageView: View {
    var imageUrl: URL?

    var body: some View {
        imageView
            .cornerRadius(8)
            .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fill)
            .frame(minWidth: 15,
                   idealWidth: 30,
                   maxWidth: 40,
                   minHeight: 15,
                   idealHeight: 30,
                   maxHeight: 40,
                   alignment: .center)
            .padding([.bottom, .trailing, .top], 10)
    }

    private var imageView: some View {
        Group {
            if let imageUrl = imageUrl {
                KFImage(imageUrl).resizable()
            } else {
                Image("defaultFeedImage").resizable()
            }
        }
    }
}

private struct NavBarButton: View {
    var body: some View {
        HStack {
            #if DEBUG
            SettingsButton()
            #endif
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
                .modifier(SystemServices())
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
                .modifier(SystemServices())
        }
    }
}

private struct AddFeedButton: View {
    @State var isPresenting = false

    var body: some View {
        Button(action: {
            self.isPresenting = true
        }, label: {
            Text("Add feed")
        })
        .sheet(isPresented: $isPresenting) {
            AddFeedView(presenting: self.$isPresenting)
                .modifier(SystemServices())
        }
    }
}

// MARK: - Previews

struct FeedRootView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                FeedRootView(feedStore: FeedStore.testStore)
            }
        }.modifier(SystemServices())
    }
}
