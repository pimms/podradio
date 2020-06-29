import SwiftUI

struct FeedRootView: View {
    var feeds: [Feed]

    var body: some View {
        List(feeds) { feed in
            NavigationLink(destination: PlayerRootView(feed: feed)) {
                FeedCell(feed: feed)
            }
        }
        .navigationTitle("Feeds")
        .navigationBarItems(trailing: AddFeedButton())
    }
}

private struct FeedCell: View {
    var feed: Feed

    var body: some View {
        HStack {
            FeedImageView(image: feed.image)

            VStack {
                Text(feed.title)
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
            .aspectRatio(contentMode: .fit)
            .frame(minWidth: 44, idealWidth: 50, maxWidth: 100, minHeight: 44, idealHeight: 50, maxHeight: 100, alignment: .center)
    }
}

private struct AddFeedButton: View {
    @State var isPresenting = false

    var body: some View {
        // Image(systemName: "plus.circle")
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
        NavigationView {
            FeedRootView(feeds: Feed.testData)
        }
    }
}
