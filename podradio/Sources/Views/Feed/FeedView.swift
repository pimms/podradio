import SwiftUI
import struct Kingfisher.KFImage

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
                        FeedCell(feed: feed)
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
            Text("TODO")
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
            Text("TODO")
            //SettingsRootView()
            //    .modifier(SystemServices())
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
    static var previews: some View {
        Group {
            NavigationView {
                FeedRootView()
                    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            }
        }
    }
}
