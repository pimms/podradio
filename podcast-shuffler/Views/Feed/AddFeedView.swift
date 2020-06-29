import SwiftUI

struct AddFeedView: View {
    @EnvironmentObject var feedStore: FeedStore

    @Binding var presenting: Bool
    @State private var feedUrl: String = ""

    var body: some View {
        NavigationView {
            VStack {
                TextField("Feed URL", text: $feedUrl, onEditingChanged: { _ in
                    print("wtf is this")
                }, onCommit: {
                    self.commitFeed()
                })
                .textContentType(.URL)
                .keyboardType(.URL)
                .autocapitalization(.none)

                if !feedUrl.isEmpty && !isValidUrl() {
                    HStack {
                        Text("Invalid feed URL")
                            .foregroundColor(.red)
                    }
                }

                Spacer()

                Button(action: commitFeed) {
                    Text("Add feed")
                }
                .disabled($feedUrl.wrappedValue.isEmpty && !isValidUrl())
            }
            .padding()
            .navigationTitle("Add a feed")
            .multilineTextAlignment(.leading)
        }
    }

    private func isValidUrl() -> Bool {
        guard let url = URL(string: feedUrl) else {
            return false
        }

        guard url.scheme == "https" else { return false }
        guard url.host != nil else { return false }

        return true
    }

    private func commitFeed() {
        guard let url = URL(string: feedUrl) else { return }

        feedStore.addFeed(from: url) { success in
            if success {
                presenting = false
            }
        }
    }
}

struct AddFeedView_Previews: PreviewProvider {
    static let feedStore = FeedStore()
    @State static var presenting = true

    static var previews: some View {
        AddFeedView(presenting: $presenting)
            .modifier(SystemServices())
    }
}
