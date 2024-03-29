import Foundation
import SwiftUI

struct PlayerControlSheet: View {
    @EnvironmentObject var player: Player
    let streamSchedule: StreamSchedule

    private var playerState: Player.PlayerState {
        if player.isConfigured(with: streamSchedule) {
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
                HStack() {
                    HStack {
                        Spacer()
                        AirPlayButton()
                            .frame(width: 30, height: 30)
                        Spacer()
                    }
                    PlayButton(playerState: playerState, onTap: {
                        player.ensureConfigured(with: streamSchedule)
                        player.togglePlay()
                    })
                    HStack {
                        Spacer()
                        FilterButton(feed: streamSchedule.feed)
                            .frame(width: 24, height: 24)
                        Spacer()
                        ScheduleButton(schedule: streamSchedule)
                            .frame(width: 24, height: 24)
                        Spacer()
                    }
                }
                Spacer()
                    .frame(width: 0, height: 20)
                ProgressBar(streamSchedule: streamSchedule)
            }
            Spacer()
                .frame(width: 0, height: 20)
        }
        .background(
            BlurView(style: .systemMaterialDark)
                .ignoresSafeArea(.all, edges: .bottom)
        )
    }
}

private struct ProgressBar: View {
    @ObservedObject var streamSchedule: StreamSchedule

    var body: some View {
        ProgressView(value: streamSchedule.currentTime, total: streamSchedule.atomDuration)
            .tint(.gray)
            .padding(.horizontal, 20)
    }
}

struct PlayerControlSheetPreviews: PreviewProvider {
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
        VStack {
            Spacer()
            PlayerControlSheet(streamSchedule: schedule)
                .environmentObject(mockPlayer)
        }
    }
}
