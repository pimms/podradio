import Foundation
import SwiftUI
import CoreData
import struct Kingfisher.KFImage

struct PlayerRootView: View {
    let feed: Feed
    @EnvironmentObject var player: Player

    var body: some View {
        GeometryReader { metrics in
            ZStack {
                VStack {
                    FeedImageView(feed: feed)
                        .frame(width: metrics.size.width)
                        .fixedSize()
                    Text(feed.title!).font(.title)
                    Text(player.atom?.title ?? "Episode title goes here")
                        .font(.headline)

                    ScrollView {
                        VStack {
                            Text(player.atom?.title ?? [String](repeating: "prompetiss\n", count: 100).joined())
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            // This is what makes us able to read the last lines.
                            // Not a good solution, but it works (right now).
                            Spacer()
                                .frame(height: 100)
                        }
                    }
                }

                VStack {
                    Spacer()
                    PlayerControlSheet(feed: feed)
                }
            }.onAppear(perform: {
                self.player.configure(with: feed)
            })
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


struct PlayerRootView_Preview: PreviewProvider {
    private static var persistenceController = PersistenceController.preview
    private static var feed: Feed {
        let moc = persistenceController.container.viewContext
        return DummyData.makeExampleFeed(context: moc)
    }

    private static var mockPlayer: Player {
        let player = Player(dummyPlayer: true)
        player.configure(with: feed)
        return player
    }

    static var previews: some View {
        PlayerRootView(feed: feed)
            .environmentObject(mockPlayer)
    }
}
