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
            }
            .padding()
        }
    }
}

struct FaqItem: Identifiable {
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
    ]
}

struct FaqView: View {
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

struct HelpView_Previews: PreviewProvider {
    static var previews: some View {
        HelpRootView()
    }
}
