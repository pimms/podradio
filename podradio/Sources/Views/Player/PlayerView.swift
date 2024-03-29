import Foundation
import SwiftUI
import CoreData

struct PlayerRootView: View {
    @ObservedObject var streamSchedule: StreamSchedule
    @EnvironmentObject var player: Player

    var body: some View {
        GeometryReader { metrics in
            ZStack {
                VStack {
                    FeedImageView(feed: streamSchedule.feed)
                        .frame(width: metrics.size.width)
                        .fixedSize()
                    Text(streamSchedule.atom.title)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                    Text(streamSchedule.atom.episode.season?.name ?? "Season")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    Text(streamSchedule.feed.title!)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)

                    ScrollView {
                        VStack {
                            Text(streamSchedule.atom.description)
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                            // This is what makes us able to read the last lines. Not a
                            // good solution, but it works (right now (still garbage tho)).
                            Spacer()
                                .frame(height: 130)
                        }
                    }
                }

                VStack {
                    Spacer()
                    PlayerControlSheet(streamSchedule: streamSchedule)
                }
            }.onAppear(perform: {
                DefaultFeedStore.setDefaultFeed(streamSchedule.feed)
                self.player.configureIfUnconfigured(with: streamSchedule)
            })
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct FeedImageView: View {
    let feed: Feed

    var body: some View {
        AsyncImage(url: feed.imageUrl) { image in
            image.resizable()
        } placeholder: {
            Color.gray.opacity(0.1)
        }
        .aspectRatio(1, contentMode: .fit)
        .cornerRadius(30)
        .shadow(color: .gray, radius: 20)
        .padding(.horizontal, 40)
        .padding(.vertical, 20)
    }
}


struct PlayerRootView_Preview: PreviewProvider {
    private static var persistenceController = PersistenceController.preview
    private static var schedule: StreamSchedule {
        let moc = persistenceController.mainContext
        let feed = DummyData.makeExampleFeed(context: moc)
        return StreamSchedule(feed: feed)
    }

    private static var mockPlayer: Player {
        let player = Player(dummyPlayer: true)
        player.configure(with: schedule)
        return player
    }

    static var previews: some View {
        PlayerRootView(streamSchedule: schedule)
            .environmentObject(mockPlayer)
    }
}
