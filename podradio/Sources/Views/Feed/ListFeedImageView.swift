import Foundation
import SwiftUI

struct ListFeedImageView: View {
    var imageUrl: URL?

    var body: some View {
        imageView
            .cornerRadius(8)
            .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fill)
            .frame(minWidth: 15,
                   idealWidth: 30,
                   maxWidth: 40,
                   minHeight: 15,
                   idealHeight: 30,
                   maxHeight: 40,
                   alignment: .center)
            .padding([.bottom, .trailing, .top], 10)
    }

    private var imageView: some View {
        Group {
            if let imageUrl = imageUrl {
                AsyncImage(url: imageUrl) { image in
                    image.resizable()
                } placeholder: {
                    Color.gray.opacity(0.1)
                }
            } else {
                Image("defaultFeedImage").resizable()
            }
        }
    }
}
