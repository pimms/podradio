import Foundation
import SwiftUI

struct PlayButton: View {
    var playerState: Player.PlayerState
    var onTap: () -> Void

    private let isLoading: Bool

    init(playerState: Player.PlayerState, onTap: @escaping () -> Void) {
        self.playerState = playerState
        self.onTap = onTap

        switch playerState {
        case .playing,
             .paused,
             .readyToPlay,
             .none:
            isLoading = false
        case .episodeTransition,
             .waitingToPlay:
            isLoading = true
        }
    }

    var playerIconSystemName: String {
        switch playerState {
        case .playing:
            return "pause.fill"
        case .paused, .readyToPlay, .none:
            return "play.fill"
        case .episodeTransition, .waitingToPlay:
            return "circle.dotted"
        }
    }

    var body: some View {
        return Button(action: playButtonTapped, label: {
            ZStack {
                Image(systemName: playerIconSystemName)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 35, height: 35, alignment: .center)

                if isLoading {
                    Text("let's pretend\nthis\nrotates")
                        .font(.system(size: 5))
                        .frame(width: 30, height: 30, alignment: .center)
                }
            }
        })
        .foregroundColor(.secondarySystemBackground)
    }

    private func playButtonTapped() {
        onTap()
    }
}

class PlayButtonPreviews: PreviewProvider {
    static var previews: some View {
        PlayButton(playerState: .paused, onTap: {})
            .previewLayout(.sizeThatFits)
        PlayButton(playerState: .playing, onTap: {})
            .previewLayout(.sizeThatFits)
            .background(.foreground)
        PlayButton(playerState: .waitingToPlay(autostart: true), onTap: {})
            .previewLayout(.sizeThatFits)
            .background(.foreground)
    }
}
