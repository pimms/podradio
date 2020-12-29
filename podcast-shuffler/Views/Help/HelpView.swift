import SwiftUI

struct HelpRootView: View {
    var body: some View {
        NavigationView {
            HelpView()
                .navigationTitle("FAQ")
        }
    }
}

private struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Spacer()
                    Image("Icon")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .cornerRadius(18)
                        .shadow(radius: 5)
                    Spacer()
                }
                .padding([.bottom])

                ForEach(FaqItem.items) { item in
                    FaqView(item: item)
                        .padding(.bottom, 30)
                }

                ContactButtonGroup()
            }
            .padding()
        }
    }
}

private struct FaqItem: Identifiable {
    var id: String { title }
    let title: String
    let description: String

    static let items: [FaqItem] = [
        FaqItem(title: "How does it work?",
                description: "APPNAME creates simulated radio channels from podcast feeds. As such, it requires RSS podcast feeds to know where to find the episodes.\n\nPlayback is performed locally, and only requires a network connection."),
        FaqItem(title: "My friends' channels are playing the same as mine",
                description: "The shuffling of episodes is done in such a way that anyone who listens to the same show with the same filter will hear the same episodes at the same time."),
        FaqItem(title: "Does APPNAME cellular data?",
                description: "Unless you are connected to WiFi, cellular data will be used for streaming."),
        FaqItem(title: "Why are not Spotify-URLs supported?",
                description: "RSS feeds are required for APPNAME to work, and Spotify does not share these publicly."),
        FaqItem(title: "Why can't I select which episode to play?",
                description: "APPNAME acts like a radio player, and just like you have no control over what the radio broadcasts, you have no control over what APPNAME plays."),
        FaqItem(title: "The app is 💩👎",
                description: "Feel free to contact me with any kind of feedback — I'm psyched if anyone uses it.")
    ]
}

private struct FaqView: View {
    let item: FaqItem

    var body: some View {
        VStack {
            HStack {
                Text(item.title)
                    .font(Font.title2.bold())
                    .lineLimit(10)
                Spacer()
            }.padding(.bottom, 5)
            HStack {
                Text(item.description)
                    .font(Font.body)
                Spacer()
            }
        }
    }
}

private struct ContactButtonGroup: View {
    var body: some View {
        HStack {
            ContactButton(imageName: "twitter", text: "@superpimms", action: {
                guard let url = URL(string: "https://twitter.com/superpimms") else { return }
                UIApplication.shared.open(url)
            })
            Spacer()
        }
    }
}

private struct ContactButton: View {
    let imageName: String
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(imageName)
                    .resizable()
                    .frame(width: 30, height: 30)
                Text(text)
                    .foregroundColor(.primary)
            }
            .padding([.leading], 20)
            .padding([.trailing], 25)
            .padding([.bottom, .top], 10)
        }
        .background(Color.tertiaryLabel)
        .cornerRadius(8)
    }
}

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HelpRootView()
            ContactButtonGroup()
                .preferredColorScheme(.light)
                .previewLayout(.sizeThatFits)
            ContactButtonGroup()
                .preferredColorScheme(.dark)
                .previewLayout(.sizeThatFits)
        }
    }
}
