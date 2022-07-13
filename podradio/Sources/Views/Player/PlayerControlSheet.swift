import Foundation
import SwiftUI

struct PlayerControlSheet: View {
    @EnvironmentObject var player: Player
    let feed: Feed

    private var playerState: Player.PlayerState {
        if player.feed == feed {
            return player.playerState
        } else {
            return .none
        }
    }

    var body: some View {
        VStack {
            Spacer()
                .frame(width: 0, height: 20)
            VStack {
                HStack {
                    Spacer()
                    AirPlayButton()
                    Spacer()
                    PlayButton(playerState: playerState, onTap: {
                        player.ensureConfigured(with: feed)
                        player.togglePlay()
                    })
                    Spacer()
                    FilterButton(feed: feed)
                    Spacer()
                }
                Spacer()
                    .frame(width: 0, height: 20)
                ProgressBar()
            }
            Spacer()
                .frame(width: 0, height: 20)
        }
        .background(
            RoundedCorners(color: .init(white: 0.75), tl: 20, tr: 20, bl: 0, br: 0)
                .ignoresSafeArea(.all, edges: .bottom)
        )
    }
}

private struct ProgressBar: View {
    @EnvironmentObject var player: Player

    var body: some View {
        ProgressView(value: player.currentTime, total: player.atom?.duration ?? 1)
            .tint(.secondarySystemBackground)
            .padding(.horizontal, 20)
    }
}

struct PlayerControlSheetPreviews: PreviewProvider {
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
        VStack {
            Spacer()
            PlayerControlSheet(feed: feed)
                .environmentObject(mockPlayer)
                .foregroundColor(.blue)
        }
    }
}
