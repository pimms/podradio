import SwiftUI

struct AddFeedView: View {
    private enum InputState {
        case noInput
        case readyToSubmit
        case invalidUrl
        case downloading
        case incorrectContent
    }

    @EnvironmentObject var feedStore: FeedStore

    @Binding var presenting: Bool
    @State private var feedUrl: String = ""
    @State private var state: InputState = .noInput

    var body: some View {
        NavigationView {
            ZStack {
                if state == .downloading {
                    LoadingView()
                }

                VStack {
                    TextField("Feed URL", text: $feedUrl, onCommit: {
                        self.commitFeed()
                    })
                    .onChange(of: feedUrl, perform: { _ in
                        if feedUrl.isEmpty {
                            state = .noInput
                        } else if !isValidUrl() {
                            state = .invalidUrl
                        } else {
                            state = .readyToSubmit
                        }
                    })
                    .textContentType(.URL)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                    if state == .invalidUrl {
                        Text("Not a valid URL").foregroundColor(.red)
                    } else if state == .incorrectContent {
                        Text("Not a valid RSS feed").foregroundColor(.red)
                    }

                    Spacer()

                    Button(action: commitFeed) {
                        Text("Add feed")
                    }
                    .disabled(state != .readyToSubmit)
                }
                .padding()
                .navigationTitle("Add a feed")
                .multilineTextAlignment(.leading)
            }
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
        state = .downloading

        feedStore.addFeed(from: url) { success in
            if success {
                presenting = false
            } else {
                self.state = .incorrectContent
            }
        }
    }
}

private struct LoadingView: View {
    var body: some View {
        GeometryReader { metrics in
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    ProgressView("Loading")
                        .frame(width: metrics.size.width * 0.4, height: metrics.size.width * 0.4, alignment: .center)
                        .background(Color.secondary.opacity(0.5))
                        .cornerRadius(10)
                        .transition(.scale)
                        .animation(.easeInOut)
                    Spacer()
                }
                Spacer()
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
