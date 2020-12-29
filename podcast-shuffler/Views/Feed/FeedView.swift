import SwiftUI
import struct Kingfisher.KFImage

struct FeedRootView: View {
    @EnvironmentObject var feedStore: FeedStore

    var body: some View {
        Group {
            let feeds = feedStore.feeds
            if feeds.isEmpty {
                NoFeedsView()
            } else {
                List() {
                    ForEach(feedStore.feeds) { feed in
                        NavigationLink(destination: PlayerRootView(feed: feed)) {
                            FeedCell(feed: feed)
                        }
                    }
                    .onDelete(perform: onDelete)
                }
            }
        }
        .navigationTitle("Feeds")
        .navigationBarItems(leading: NavBarButton(), trailing: AddFeedButton())
    }

    private func onDelete(_ indexSet: IndexSet) {
        Array(indexSet)
            .map { feedStore.feeds[$0] }
            .forEach { feedStore.deleteFeed($0) }
    }
}

private struct NoFeedsView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("No feeds!")
                .font(Font.largeTitle.bold())
                .padding(.bottom)
            Text("Add your favorite podcast to start listening.")
                .font(Font.title2.bold())
                .multilineTextAlignment(.center)
            Spacer()
        }
        .opacity(0.2)
        .padding()
    }
}

private struct FeedCell: View {
    var feed: Feed

    var body: some View {
        HStack {
            FeedImageView(imageUrl: feed.imageUrl)

            VStack {
                HStack {
                    Text(feed.title)
                    Spacer()
                }
                HStack {
                    Text(feed.url.absoluteString)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.top, 2)
            }
        }
    }
}

private struct FeedImageView: View {
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
                FeedRootView()
                    .modifier(SystemServices())
            }

            NoFeedsView()
        }.modifier(SystemServices())
    }
}
