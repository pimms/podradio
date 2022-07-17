import Foundation
import CoreData
import SwiftUI

struct FilterRootView: View {
    let feed: Feed

    var body: some View {
        NavigationView {
            FilterView(feed: feed)
                .navigationTitle("filter.yearly.title")
        }
    }
}

private struct FilterView: View {
    let feed: Feed
    @Environment(\.managedObjectContext) private var managedObjectContext

    private var fetchRequest: FetchRequest<Season>
    @State private var selectedSeasonIds: [String]

    init(feed: Feed) {
        self.feed = feed
        self.fetchRequest = FetchRequest(
            entity: Season.entity(),
            sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)],
            predicate: NSPredicate(format: "feed.url == %@", feed.url!.absoluteString))

        _selectedSeasonIds = .init(initialValue: feed.filter?.includedSeasons ?? [])
    }

    var body: some View {
        List(fetchRequest.wrappedValue) { season in
            MultipleSelectionRow(
                title: "\(season.name!)",
                description: "filter.yearly.episodeCount \(season.episodes!.count)",
                isSelected: selectedSeasonIds.contains(season.uniqueId!),
                action: { seasonTapped(season) })
        }
    }

    private func seasonTapped(_ season: Season) {
        // Add/remove the season from the filter
        let seasonId = season.uniqueId!
        if selectedSeasonIds.contains(seasonId) {
            selectedSeasonIds.removeAll(where: { $0 == seasonId })
        } else {
            selectedSeasonIds.append(seasonId)
        }

        // Update the CD entities
        if selectedSeasonIds.isEmpty {
            if let filter = feed.filter {
                managedObjectContext.delete(filter)
                feed.filter = nil
            }
        } else {
            if feed.filter == nil {
                let filter = SeasonFilter(context: managedObjectContext)
                filter.includedSeasons = selectedSeasonIds
                feed.filter = filter
            } else {
                feed.filter!.includedSeasons = selectedSeasonIds
                feed.filter = feed.filter
            }
        }

        // Persist
        do {
            try managedObjectContext.save()
        } catch {
            assertionFailure("Failed to update season filter")
            managedObjectContext.rollback()
        }
    }
}

private struct MultipleSelectionRow: View {
    var title: LocalizedStringKey
    var description: LocalizedStringKey
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack {
                    HStack {
                        Text(title)
                        Spacer()
                    }
                    HStack {
                        Text(description)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                if isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}

struct FilterRootView_Previews: PreviewProvider {
    static var feed: Feed {
        let context = PersistenceController.preview.mainContext
        return DummyData.makeFeed(context: context, title: "Some Feed", episodeCount: 1000)
    }

    static var previews: some View {
        FilterRootView(feed: feed)
    }
}
