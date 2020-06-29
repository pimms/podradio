import SwiftUI

struct AppRootView: View {
    @EnvironmentObject var feedStore: FeedStore

    var body: some View {
        NavigationView {
            FeedRootView(feeds: feedStore.feeds)
        }
    }
}

struct AppRootView_Previews: PreviewProvider {
    static var previews: some View {
        AppRootView().modifier(SystemServices())
    }
}
