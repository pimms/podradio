import Foundation
import SwiftUI

struct NoFeedsView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("frontpage.noFeeds.title")
                .font(Font.largeTitle.bold())
                .padding(.bottom)
            Text("frontpage.noFeeds.desc")
                .font(Font.title2.bold())
                .multilineTextAlignment(.center)
            Spacer()
        }
        .opacity(0.2)
        .padding()
    }
}

struct NoFeedsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NoFeedsView()
        }.modifier(SystemServices())
    }
}
