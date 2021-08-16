import Foundation
import CoreData
import SwiftUI

struct FilterRootView: View {
    let feed: Feed

    var body: some View {
        NavigationView {
            FilterView(feed: feed)
                .navigationTitle("filter.title")
        }
    }
}

private struct FilterView: View {
    private struct Year: Identifiable {
        let value: Int
        let episodeCount: Int
        let selected: Bool

        var id: Int { value }
    }

    let feed: Feed
    @Environment(\.managedObjectContext) private var managedObjectContext

    private var years: [Year] {
        let years = feed.episodes?.allObjects
            .compactMap({ $0 as? Episode })
            .map({ $0.year }) ?? []

        var counts: [Int: Int] = [:]
        for year in years {
            counts[year] = (counts[year] ?? 0) + 1
        }

        let uniqueYears = Set(years).sorted()
        let selected = selectedYears

        return uniqueYears.map {
            Year(value: $0,
                 episodeCount: counts[$0] ?? 0,
                 selected: selected.contains($0))
        }
    }
    @State private var selectedYears: [Int]

    init(feed: Feed) {
        self.feed = feed
        let years: [Int] = feed.filter?.includedSeasons?.compactMap({ Int($0) }) ?? []
        self._selectedYears = .init(initialValue: years)
    }

    var body: some View {
        List(years) { year in
            MultipleSelectionRow(title: "\(String(year.value))",
                                 description: "filter.yearly.episodeCount \(year.episodeCount)",
                                 isSelected: year.selected) {
                yearTapped(year)
            }
        }
    }

    private func yearTapped(_ year: Year) {
        if selectedYears.contains(year.value) {
            selectedYears.removeAll(where: { $0 == year.value })
        } else {
            selectedYears.append(year.value)
        }

        if selectedYears.isEmpty {
            if let filter = feed.filter {
                managedObjectContext.delete(filter)
            }
            feed.filter = nil
        } else {
            let filter = FeedFilter(context: managedObjectContext)
            filter.includedSeasons = selectedYears.map(String.init)
            feed.filter = filter
        }

        do {
            try managedObjectContext.save()
        } catch {
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
        let context = PersistenceController.preview.container.viewContext
        return DummyData.makeFeed(context: context, title: "Some Feed", episodeCount: 1000)
    }

    static var previews: some View {
        FilterRootView(feed: feed)
    }
}
