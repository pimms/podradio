import Foundation
import SwiftUI
import CoreData
import struct Kingfisher.KFImage

struct PlayerRootView: View {
    let streamSchedule: StreamSchedule
    @EnvironmentObject var player: Player

    var atom: StreamAtom { streamSchedule.currentAtom() }

    var body: some View {
        GeometryReader { metrics in
            ZStack {
                VStack {
                    FeedImageView(feed: streamSchedule.feed)
                        .frame(width: metrics.size.width)
                        .fixedSize()
                    Text(atom.title)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                    Text(atom.episode.season?.name ?? "Season")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                    Text(streamSchedule.feed.title!)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)

                    ScrollView {
                        VStack {
                            Text(atom.description)
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
                self.player.configureIfUnconfigured(with: streamSchedule)
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
    private static var schedule: StreamSchedule {
        let moc = persistenceController.container.viewContext
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
