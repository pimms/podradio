import Foundation
import SwiftUI

struct SettingsRootView: View {
    var body: some View {
        NavigationView {
            SettingsView()
                .navigationTitle("settings.title")
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
            Toggle("settings.bingePicker", isOn: $useBingeEpisodePicker)
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
                    VStack {
                        HStack {
                            Text("settings.feed.lastRefreshed")
                                .font(.footnote)
                            Spacer()
                        }
                        HStack {
                            Text("settings.feed.episodeCount")
                                .font(.footnote)
                            Spacer()
                        }
                        HStack {
                            Text("settings.feed.lastEpisodeDate")
                                .font(.footnote)
                            Spacer()
                        }
                    }
                    VStack {
                        HStack {
                            lastRefreshText
                                .fontWeight(.semibold)
                                .font(.footnote)
                            Spacer()
                        }
                        HStack {
                            Text("\(String(feed.episodes.count))")
                                .fontWeight(.semibold)
                                .font(.footnote)
                            Spacer()
                        }
                        HStack {
                            Text("\(feed.episodes.sorted(by: { $0.date < $1.date }).last?.date ?? Date(), formatter: Self.dateFormatter)")
                                .fontWeight(.semibold)
                                .font(.footnote)
                            Spacer()
                        }
                    }
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
                    Button("settings.feed.refresh", action: { feedStore.refreshFeed(feed) })
                }
            }
            Section {
                Button("settings.feed.delete", action: {
                    self.showingAlert = true
                }).alert(isPresented: $showingAlert) {
                    Alert(title: Text("settings.feed.delete.alertTitle"),
                          message: Text("settings.feed.delete.alertMessage \(feed.title)"),
                          primaryButton: .destructive(Text("settings.feed.delete"), action: { feedStore.deleteFeed(feed) }),
                          secondaryButton: .cancel())
                }
                .foregroundColor(.red)
            }
        }
    }

    private var lastRefreshText: Text {
        let refreshDate = feedStore.lastRefreshDate(for: feed)
        if refreshDate.timeIntervalSinceNow > -5 {
            return Text("settings.feed.lastRefreshed.justNow")
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
