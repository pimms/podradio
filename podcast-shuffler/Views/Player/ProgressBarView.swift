import Foundation
import SwiftUI

struct ProgressBarView: View {
    @StateObject var player: EpisodePlayer

    var body: some View {
        VStack {
            ProgressBar(currentTime: player.currentTime, duration: player.duration)
            HStack {
                Text(formattedDuration(player.currentTime))
                    .font(.callout)
                    .foregroundColor(.secondary)
                Spacer()
                Text(formattedDuration(player.duration))
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
        }
    }

    func formattedDuration(_ timeInterval: TimeInterval) -> String {
        let intValue = Int(timeInterval)

        let hours = intValue / 3600
        let hourString = hours > 0 ? "\(hours):" : ""

        let minutes = (intValue % 3600) / 60
        let minuteString = "\(minutes < 10 ? "0" : "")\(minutes):"

        let seconds = (intValue % 60)
        let secondString = "\(seconds < 10 ? "0" : "")\(seconds)"

        return "\(hourString)\(minuteString)\(secondString)"
    }
}

fileprivate struct ProgressBar: View {
    let currentTime: TimeInterval
    let duration: TimeInterval

    var body: some View {
        GeometryReader { metrics in
            ZStack {
                Rectangle()
                    .foregroundColor(Color.secondary)
                    .cornerRadius(metrics.size.height / 2)

                HStack {
                    Rectangle()
                        .frame(width: metrics.size.width * ratio)
                        .foregroundColor(.primary)
                        .cornerRadius(metrics.size.height / 2)
                    Spacer(minLength: 0)
                }
            }
        }
    }

    private var ratio: CGFloat {
        if duration == 0 {
            return 0
        }
        return CGFloat(currentTime) / CGFloat(duration)
    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBarView(player: EpisodePlayer())
            .frame(maxHeight: 40)
            .previewLayout(.sizeThatFits)
            .padding()

        ProgressBar(currentTime: 0.4, duration: 1)
            .frame(maxHeight: 40)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
