import Foundation
import SwiftUI
import CoreData
import struct Kingfisher.KFImage

struct PlayerRootView: View {
    let feed: Feed

    var body: some View {
        VStack {
            FeedImageView(feed: feed)
            Text(feed.title!).font(.title)
            Spacer()
            PlayControlSheet(feed: feed)
        }
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
            HStack {
                Spacer()
                AirPlayButton()
                Spacer()
                PlayButton()
                Spacer()
                FilterButton(feed: feed)
                Spacer()
            }
            Spacer().frame(width: 0, height: 20)
        }
        .background(
            RoundedCorners(color: .tertiaryLabel, tl: 20, tr: 20, bl: 0, br: 0)
                .ignoresSafeArea(.all, edges: .bottom)
        )
    }
}

private struct PlayButton: View {
    var body: some View {
        Button(action: playButtonTapped, label: {
            Image(systemName: "play.fill")
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 35, height: 35, alignment: .center)
        })
        .foregroundColor(.secondarySystemBackground)
    }

    private func playButtonTapped() {
        print("Play button tapped")
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
    private static var feed: Feed {
        let moc = PersistenceController.preview.container.viewContext
        let req = Feed.fetchRequest()
        let result = try! moc.fetch(req)
        return result.first!
    }

    static var previews: some View {
        PlayerRootView(feed: feed)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
