import SwiftUI

struct AppRootView: View {
    var body: some View {
        NavigationView {
            FeedRootView()
        }
    }
}

struct AppRootView_Previews: PreviewProvider {
    static var previews: some View {
        AppRootView().modifier(SystemServices())
    }
}
