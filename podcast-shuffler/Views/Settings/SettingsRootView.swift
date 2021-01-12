import Foundation
import SwiftUI

struct SettingsRootView: View {
    var body: some View {
        NavigationView {
            SettingsView()
                .navigationTitle("Settings")
        }
    }
}

fileprivate struct SettingsView: View {
    @AppStorage(StorageKey.useBingeEpisodePicker.rawValue)
    private var useBingeEpisodePicker = false

    @EnvironmentObject
    private var feedStore: FeedStore

    var body: some View {
        Form {
            #if DEBUG
            Toggle("Use binge episode picker", isOn: $useBingeEpisodePicker)
            #endif

            ForEach(feedStore.feeds) { feed in
                FeedSettingsView(feedStore: feedStore,  feed: feed)
            }
        }
    }
}

fileprivate struct FeedSettingsView: View {
    static let dateFormatter = RelativeDateTimeFormatter()

    let feedStore: FeedStore
    let feed: Feed

    @State private var showingAlert = false

    var body: some View {
        Section {
            VStack {
                HStack {
                    FeedImageView(imageUrl: feed.imageUrl)
                    Text(feed.title)
                    Spacer()
                }

                Spacer()
                HStack {
                    Text("Last refreshed:")
                        .font(.footnote)
                    lastRefreshText
                        .font(.footnote)
                    Spacer()
                }
                Spacer()
                HStack {
                    Text(feed.url.absoluteString)
                        .font(.caption2)
                        .fontWeight(.light)
                    Spacer()
                }
                Spacer()
            }

            Section {
                Section {
                    Button("Refresh", action: { feedStore.refreshFeed(feed) })
                }
            }
            Section {
                Button("Delete", action: {
                    self.showingAlert = true
                }).alert(isPresented: $showingAlert) {
                    Alert(title: Text("Delete"),
                          message: Text("Do you really want to delete '\(feed.title)'?"),
                          primaryButton: .destructive(Text("Delete"), action: { feedStore.deleteFeed(feed) }),
                          secondaryButton: .cancel())
                }
                .foregroundColor(.red)
            }
        }
    }

    private var lastRefreshText: Text {
        let refreshDate = feedStore.lastRefreshDate(for: feed)
        if refreshDate.timeIntervalSinceNow > -5 {
            return Text("just now")
        }
        return Text("\(refreshDate, formatter: Self.dateFormatter)")
    }
}

class SettingsRootView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsRootView()
            .environmentObject(FeedStore.testStore)
    }
}
