import SwiftUI

struct FeedRootView: View {
    @EnvironmentObject var feedStore: FeedStore

    var body: some View {
        List {
            ForEach(feedStore.feeds) { feed in
                NavigationLink(destination: PlayerRootView(feed: feed)) {
                    FeedCell(feed: feed)
                }
            }
            .onDelete(perform: onDelete)
        }
        .navigationTitle("Feeds")
        .navigationBarItems(trailing: AddFeedButton())
    }

    private func onDelete(_ indexSet: IndexSet) {
        Array(indexSet)
            .map { feedStore.feeds[$0] }
            .forEach { feedStore.deleteFeed($0) }
    }
}

private struct FeedCell: View {
    var feed: Feed

    var body: some View {
        HStack {
            FeedImageView(image: feed.image)

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
    var image: UIImage?

    var body: some View {
        var imageView: Image
        if let image = image {
            imageView = Image(uiImage: image)
        } else {
            imageView = Image("defaultFeedImage")
        }

        return imageView
            .resizable()
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
            NavigationView {
                FeedRootView()
                    .modifier(SystemServices())
            }
        }.modifier(SystemServices())
    }
}
