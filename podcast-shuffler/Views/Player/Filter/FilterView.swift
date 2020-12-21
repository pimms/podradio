import Foundation
import SwiftUI

struct FilterRootView: View {
    var feed: Feed

    var body: some View {
        YearFilterList(feed: feed)
    }
}

struct YearFilterList: View {
    private struct Year: Identifiable {
        let value: Int
        var id: Int { value }
    }

    var feed: Feed

    var body: some View {
        List(years) { year in
            Text(String(year.value))
        }
    }

    private var years: [Year] {
        let years = feed.episodes.map { $0.year }
        let uniqueYears = Set(years).sorted()
        print("Unique years: \(uniqueYears)")
        return uniqueYears.map { Year(value: $0) }
    }
}

struct FilterRootView_Previews: PreviewProvider {
    static var previews: some View {
        FilterRootView(feed: Feed.testData[0])
    }
}
