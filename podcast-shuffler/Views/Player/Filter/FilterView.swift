import Foundation
import SwiftUI

struct FilterRootView: View {
    var feed: Feed

    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        NavigationView {
            YearFilterList(feed: feed)
                .navigationBarTitle("Yearly Filter", displayMode: .inline)
                .navigationBarItems(trailing:
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Text("Done").bold()
                    }
                )
        }.modifier(SystemServices())
    }
}

struct YearFilterList: View {
    private struct Year: Identifiable {
        let value: Int
        let episodeCount: Int
        let selected: Bool

        var id: Int { value }
    }

    var feed: Feed
    private var years: [Year] {
        let years = feed.episodes.map { $0.year }

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
        let years: [Int] = (FilterStore.shared.filter(for: feed) as? YearFilter)?.years ?? []
        self._selectedYears = .init(initialValue: years)
    }

    var body: some View {
        List(years) { year in
            MultipleSelectionRow(title: "\(String(year.value))",
                                 description: "\(year.episodeCount) episodes",
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
            FilterStore.shared.setFilter(BaseFilter(feed: feed))
        } else {
            let filter = YearFilter(feed: feed, years: selectedYears)
            FilterStore.shared.setFilter(filter)
        }
    }
}

struct MultipleSelectionRow: View {
    var title: String
    var description: String
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
    static var previews: some View {
        FilterRootView(feed: Feed.testData[0])
    }
}
