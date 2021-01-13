import Foundation
import SwiftUI

struct FeedHelpRootView: View {
    var body: some View {
        TabView {
            InitialHelpView()
            HelpProcessView(iconImage: "Apple-Icon", title: "help.apple.title", items: HelpItem.appleItems)
            HelpProcessView(iconImage: nil, title: "help.other.title", items: HelpItem.genericItems)
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarTitleDisplayMode(.inline)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
    }
}

private struct InitialHelpView: View {
    var body: some View {
        VStack {
            HStack {
                Text("help.intro.title")
                    .font(Font.title.bold())
                    .padding()
                Spacer()
            }
            Text("help.intro.desc")
                .multilineTextAlignment(.leading)
                .font(Font.body)
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
    let title: LocalizedStringKey
    let description: LocalizedStringKey

    static let appleItems = [
        HelpItem(imageName: "Apple-1", title: "help.apple.step1.title", description: "help.apple.step1.desc"),
        HelpItem(imageName: "Apple-2", title: "help.apple.step2.title", description: "help.apple.step2.desc"),
    ]

    static let genericItems = [
        HelpItem(imageName: "Generic-1", title: "help.other.step1.title", description: "help.other.step1.desc")
    ]
}

private struct HelpProcessView: View {
    let iconImage: String?
    let title: LocalizedStringKey
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
