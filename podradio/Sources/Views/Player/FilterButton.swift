import Foundation
import SwiftUI

struct FilterButton: View {
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
