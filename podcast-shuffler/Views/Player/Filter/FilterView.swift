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
        }
    }
}

struct YearFilterList: View {
    private struct Year: Identifiable {
        let value: Int
        var id: Int { value }
        let selected: Bool
    }

    var feed: Feed
    private var years: [Year] {
        let years = feed.episodes.map { $0.year }
        let uniqueYears = Set(years).sorted()
        let selected = selectedYears

        return uniqueYears.map { Year(value: $0, selected: selected.contains($0)) }
    }
    @State private var selectedYears: [Int]

    init(feed: Feed) {
        self.feed = feed
        let years: [Int] = (FilterStore.shared.filter(for: feed) as? YearFilter)?.years ?? []
        self._selectedYears = .init(initialValue: years)
    }

    var body: some View {
        List(years) { year in
            MultipleSelectionRow(title: "\(year.value)", isSelected: year.selected) {
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

        print("selected years: \(selectedYears)")

        if selectedYears.isEmpty {
            FilterStore.shared.removeFilter(for: feed)
        } else {
            let filter = YearFilter(feed: feed, years: selectedYears)
            FilterStore.shared.setFilter(filter, for: feed)
        }
    }
}

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: self.action) {
            HStack {
                Text(self.title)
                if self.isSelected {
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
