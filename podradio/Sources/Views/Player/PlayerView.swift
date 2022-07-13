import Foundation
import SwiftUI
import CoreData
import struct Kingfisher.KFImage

struct PlayerRootView: View {
    let feed: Feed
    @EnvironmentObject var player: Player

    // TODO: We are currently only displaying the currently playing atom, even if
    // `feed` is not the feed being played.
    var body: some View {
        GeometryReader { metrics in
            ZStack {
                VStack {
                    FeedImageView(feed: feed)
                        .frame(width: metrics.size.width)
                        .fixedSize()
                    Text(player.atom?.title ?? "Title")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                    Text(player.atom?.episode.season?.name ?? "Season")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    Text(feed.title!)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)

                    ScrollView {
                        VStack {
                            Text(player.atom?.description ?? "")
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
                self.player.configureIfUnconfigured(with: feed)
            })
        }
        .navigationBarTitleDisplayMode(.inline)
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
            .padding(.horizontal, 40)
            .padding(.vertical, 20)
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
