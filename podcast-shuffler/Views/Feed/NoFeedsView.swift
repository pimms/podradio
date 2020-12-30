import Foundation
import SwiftUI

struct NoFeedsView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("No feeds!")
                .font(Font.largeTitle.bold())
                .padding(.bottom)
            Text("Add your favorite podcast to start listening.")
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
