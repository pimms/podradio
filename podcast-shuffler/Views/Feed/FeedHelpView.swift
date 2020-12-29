import Foundation
import SwiftUI

struct FeedHelpRootView: View {
    var body: some View {
        TabView {
            HelpProcessView(iconImage: "Apple-Icon", title: "Apple Podcasts", items: HelpItem.appleItems)
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationTitle("Finding the URL")
        .navigationBarTitleDisplayMode(.inline)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
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
}

private struct HelpProcessView: View {
    let iconImage: String
    let title: String
    let items: [HelpItem]

    var body: some View {
        GeometryReader { metrics in
            ScrollView {
                VStack {
                    HStack {
                        Image(iconImage)
                            .resizable()
                            .frame(width: 44, height: 44)
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(8)
                            .shadow(radius: 2)
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
