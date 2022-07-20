import Foundation
import SwiftUI
import UIKit
import MediaPlayer

struct AirPlayButton: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        let returnView: UIView
        if isRunningPreviews() {
            let image = UIImage(systemName: "airplayaudio")
            let imageView = UIImageView(image: image)
            returnView = imageView
        } else {
            let volumeView = MPVolumeView(frame: .zero)
            volumeView.showsVolumeSlider = false
            returnView = volumeView
        }

        return returnView
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        // nope
    }
}
