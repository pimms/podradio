import Foundation
import SwiftUI
import UIKit
import MediaPlayer

struct AirPlayButton: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        let view = MPVolumeView(frame: .zero)
        view.showsVolumeSlider = false
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        // nope
    }
}
