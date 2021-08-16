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
            PlayControlSheet()
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
            .shadow(color: .label, radius: 20)
            .padding(30)
    }
}

private struct PlayControlSheet: View {
    var body: some View {
        VStack {
            Spacer().frame(width: 0, height: 20)
            HStack {
                Spacer()
                AirPlayButton()
                Spacer()
                Image(systemName: "play.fill")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 35, height: 35, alignment: .center)
                Spacer()
                FilterButton()
                Spacer()
            }
            Spacer().frame(width: 0, height: 20)
        }
        .background(RoundedCorners(color: .tertiaryLabel, tl: 20, tr: 20, bl: 0, br: 0)
                        .ignoresSafeArea(.all, edges: .bottom)
        )

    }
}

struct FilterButton: View {
    var body: some View {
        Image(systemName: "line.horizontal.3.decrease.circle")
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
