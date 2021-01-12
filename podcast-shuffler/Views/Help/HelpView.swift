import SwiftUI

struct HelpRootView: View {
    var body: some View {
        NavigationView {
            HelpView()
                .navigationTitle("faq.title")
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
    private static var counter: Int = 0
    private static var nextId: Int {
        counter += 1
        return counter
    }

    let id: Int = Self.nextId
    let title: LocalizedStringKey
    let description: LocalizedStringKey

    static let items: [FaqItem] = [
        FaqItem(title: "faq.item1.title",
                description: "faq.item1.desc"),
        FaqItem(title: "faq.item2.title",
                description: "faq.item2.desc"),
        FaqItem(title: "faq.item3.title",
                description: "faq.item3.desc"),
        FaqItem(title: "faq.item4.title",
                description: "faq.item4.desc"),
        FaqItem(title: "faq.item5.title",
                description: "faq.item5.desc"),
        FaqItem(title: "faq.item6.title",
                description: "faq.item6.desc")
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
