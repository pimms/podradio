import Foundation
import SwiftUI

struct ListFeedImageView: View {
    @State var imageUrl: URL?

    var body: some View {
        AsyncImage(url: imageUrl) { image in
            image
                .resizable()
                .aspectRatio(1, contentMode: .fit)
        } placeholder: {
            Rectangle()
                .background(Color.gray)
                .opacity(0.1)
        }
        .cornerRadius(8)
        .frame(minWidth: 15,
               idealWidth: 30,
               maxWidth: 40,
               minHeight: 15,
               idealHeight: 30,
               maxHeight: 40,
               alignment: .center)
        .padding([.bottom, .trailing, .top], 10)
    }
}
