import Foundation
import SwiftUI

struct FeedHelpRootView: View {
    var body: some View {
        TabView {
            InitialHelpView()
            HelpProcessView(iconImage: "Apple-Icon", title: "Apple Podcasts", items: HelpItem.appleItems)
            HelpProcessView(iconImage: nil, title: "Other apps", items: HelpItem.genericItems)
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationTitle("Finding the URL")
        .navigationBarTitleDisplayMode(.inline)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
    }
}

private struct InitialHelpView: View {
    var body: some View {
        VStack {
            Text("Finding the feed URL")
                .font(Font.title.bold())
                .padding()
            Text("Adding feeds is kind of technical, but it's something you only need to do once.\n\nIf your favorite app is not included, remember that you can (almost) always use the built-in Podcast application to find the feed.\n\nScroll to learn more.")
                .multilineTextAlignment(.leading)
                .padding()
            Image(systemName: "arrow.forward.circle")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.accentColor)
            Spacer()
        }
    }
}

private struct HelpItem: Identifiable {
    var id: String { imageName }
    let imageName: String
    let title: String
    let description: String

    static let appleItems = [
        HelpItem(imageName: "Apple-1", title: "Step 1", description: "Find the podcast in the app."),
        HelpItem(imageName: "Apple-2", title: "Step 2", description: "Long press and tap the 'Copy Link' button."),
    ]

    static let genericItems = [
        HelpItem(imageName: "Generic-1", title: "Search the web", description: "Feed URLs are unfortunately not often exposed by podcast applications, but the podcast creators often have feeds available. Try searching the web.\n\nI'm rooting for you! 🤞")
    ]
}

private struct HelpProcessView: View {
    let iconImage: String?
    let title: String
    let items: [HelpItem]

    var body: some View {
        GeometryReader { metrics in
            ScrollView {
                VStack {
                    HStack {
                        if let iconImage = iconImage {
                            Image(iconImage)
                                .resizable()
                                .frame(width: 44, height: 44)
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(8)
                                .shadow(radius: 2)
                        }
                        Text(title)
                            .font(Font.title.bold())
                            .padding()
                    }
                    ForEach(items) { item in
                        HelpItemView(item: item)
                            .frame(height: metrics.size.height * 0.8)
                    }
                }.padding([.bottom, .top])
            }
        }
    }
}

private struct HelpItemView: View {
    let item: HelpItem

    var body: some View {
        VStack {
            Text(item.title)
                .font(Font.title3.bold())

            HStack {
                Spacer()
                Image(item.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(10)
                    .shadow(color: .tertiaryLabel, radius: 5)
                Spacer()
            }
            Text(item.description)
                .font(.callout)
                .padding([.leading, .trailing])
                .multilineTextAlignment(.center)
        }
        .padding(.bottom)
    }
}

struct FeedHelpView_Previews: PreviewProvider {
    static var previews: some View {
        FeedHelpRootView()
            .edgesIgnoringSafeArea(.all)
    }
}
