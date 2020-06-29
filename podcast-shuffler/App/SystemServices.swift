import Foundation
import SwiftUI

/// https://medium.com/swlh/swiftui-and-the-missing-environment-object-1a4bf8913ba7
struct SystemServices: ViewModifier {
    static let feedStore = FeedStore()

    func body(content: Content) -> some View {
        content
            .accentColor(.purple)
            .environmentObject(Self.feedStore)
            .padding()
    }
}
