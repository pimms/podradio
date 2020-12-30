import SwiftUI

struct AppRootView: View {
    var body: some View {
        NavigationView {
            FeedRootView()

            // This view will only be visible on iPad
            NoFeedsView()
        }
    }
}

struct AppRootView_Previews: PreviewProvider {
    static var previews: some View {
        AppRootView().modifier(SystemServices())
    }
}
