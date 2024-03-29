import Foundation
import SwiftUI
import CoreData

struct SettingsRootView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Feed.title, ascending: true)],
        animation: .none)
    private var feeds: FetchedResults<Feed>
    @Environment(\.managedObjectContext) private var managedObjectContext

    var body: some View {
        NavigationView {
            List() {
                ForEach(feeds) { feed in
                    FeedSettingsView(feed: feed)
                }
                .onDelete(perform: onDelete(at:))

                #if DEBUG
                Section(header: Text("Debug")) {
                    DebugInfoView()
                }
                #endif
            }
            .navigationTitle(LocalizedStringKey("settings.title"))
        }
}

    private func onDelete(at offsets: IndexSet) {
        for index in offsets {
            let feed = feeds[index]
            managedObjectContext.delete(feed)
        }

        do {
            try managedObjectContext.save()
        } catch {
            managedObjectContext.rollback()
        }
    }
}

private struct FeedSettingsView: View {
    private static let dateFormatter = RelativeDateTimeFormatter()

    var feed: Feed
    var episodeFetchRequest: FetchRequest<Episode>
    var seasonFetchRequest: FetchRequest<Season>
    @State private var isRefreshing: Bool = false

    @Environment(\.managedObjectContext) private var managedObjectContext

    init(feed: Feed) {
        self.feed = feed
        episodeFetchRequest = FetchRequest<Episode>(
            entity: Episode.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "feed.url == %@", feed.url!.absoluteString))
        seasonFetchRequest = FetchRequest<Season>(
            entity: Season.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "feed.url == %@", feed.url!.absoluteString))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                ListFeedImageView(imageUrl: feed.imageUrl)
                Text(feed.title ?? "")
                    .font(.title3)
            }
            Text("settings.feed.episodeCount \(episodeFetchRequest.wrappedValue.count)")
            Text("settings.feed.seasonCount \(seasonFetchRequest.wrappedValue.count)")
            Text("settings.feed.lastRefreshed \(lastRefreshString())")
            Spacer()
            HStack(alignment: .center) {
                Spacer()
                Button("settings.feed.refreshAction", action: refresh)
                    .disabled(isRefreshing)
                Spacer()
            }
            Spacer()
        }
    }

    private func lastRefreshString() -> String {
        guard let lastRefresh = feed.lastRefresh else { return "" }

        let now = Date()
        let delta = now.timeIntervalSince1970 - lastRefresh.timeIntervalSince1970
        if delta < 30 {
            return NSLocalizedString("settings.feed.refreshedNow", comment: "Now")
        }

        return Self.dateFormatter.localizedString(for: lastRefresh, relativeTo: now)
    }

    private func refresh() {
        isRefreshing = true
        let feedFetcher = FeedFetcher(managedObjectContext: managedObjectContext)
        feedFetcher.fetchFeed(from: feed.url!) { _ in
            isRefreshing = false
        }
    }
}

private struct DebugInfoView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Feed.title, ascending: true)],
        animation: .none)
    private var feeds: FetchedResults<Feed>

    @FetchRequest(
        sortDescriptors: [],
        animation: .none)
    private var episodes: FetchedResults<Episode>

    var body: some View {
        Text("\(feeds.count) total feeds")
        Text("\(episodes.count) total episodes")
    }
}

struct SettingsRootView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            SettingsRootView()
                .environment(\.managedObjectContext,
                             PersistenceController.preview.mainContext)
        }
    }
}
