import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var feedStore: FeedStore

    var body: some View {
        Group {
            if feedStore.feedsLoaded {
                NavigationView() {
                    FeedRootView(feedStore: feedStore)

                    // This view will only be visible on iPad
                    NoFeedsView()
                }
            } else {
                EmptyView()
            }
        }
    }
}

struct AppRootView_Previews: PreviewProvider {
    static var previews: some View {
        AppRootView().modifier(SystemServices())
    }
}
