import SwiftUI

struct AddFeedView: View {
    private enum InputState {
        case noInput
        case readyToSubmit
        case invalidUrl
        case spotifyUrl
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
                    TextField("addFeed.input.placeholderText", text: $feedUrl, onCommit: {
                        if state == .readyToSubmit {
                            self.commitFeed()
                        }
                    })
                    .onChange(of: feedUrl, perform: { _ in
                        if feedUrl.isEmpty {
                            state = .noInput
                        } else if !isValidUrl() {
                            state = .invalidUrl
                        } else if isSpotifyUrl() {
                            state = .spotifyUrl
                        } else {
                            state = .readyToSubmit
                        }
                    })
                    .textContentType(.URL)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                    if state == .invalidUrl {
                        Text("addFeed.error.invalidUrl").foregroundColor(.red)
                    } else if state == .spotifyUrl {
                        Text("addFeed.error.spotifyUrl").foregroundColor(.red)
                    } else if state == .incorrectContent {
                        Text("addFeed.error.invalidRss").foregroundColor(.red)
                    }

                    Spacer()

                    NavigationLink("addFeed.feedHelpLinkTitle", destination: FeedHelpRootView())
                        .padding(.bottom, 20)

                    Button(action: commitFeed) {
                        Text("addFeed.commitTitle")
                    }
                    .disabled(state != .readyToSubmit)
                    .padding(.bottom, 20)
                }
                .padding()
                .navigationTitle("addFeed.title")
                .multilineTextAlignment(.leading)
            }
        }
    }

    private func isValidUrl() -> Bool {
        guard let _ = URL(string: feedUrl) else {
            return false
        }

        return true
    }

    private func isSpotifyUrl() -> Bool {
        return feedUrl.contains("open.spotify.com")
    }

    private func commitFeed() {
        guard var url = URL(string: feedUrl) else { return }

        /// If specifying a URL on the form 'example.com/path', the entire URL is considered the path, and
        /// this makes `url.host == nil` and `url.path == "example.com/path`. This doesn't
        /// really matter, but when forcefully adding `https` later, the URL becomes `https:example.com/path`.
        /// THIS IS ALSO FINE, but when displaying the URL it looks unfamiliar, and when exporting it becomes useless.
        ///
        /// Therefore, dirtily add `https://` prefix.
        if url.host == nil && url.scheme == nil {
            guard let httpsUrl = URL(string: "https://\(url.absoluteString)") else { return }
            url = httpsUrl
        }

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
                    ProgressView("addFeed.loading")
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
