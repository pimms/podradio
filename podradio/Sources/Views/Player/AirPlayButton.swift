import Foundation
import SwiftUI
import UIKit
import MediaPlayer

struct AirPlayButton: View {
    var body: some View {
        AirPlayButtonRepresentable()
            .frame(width: 40, height: 40, alignment: .center)
    }
}

private struct AirPlayButtonRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<AirPlayButtonRepresentable>) -> UIViewController {
        return AirPlayViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<AirPlayButtonRepresentable>) {

    }
}

private class AirPlayViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIButton()
        let boldConfig = UIImage.SymbolConfiguration(scale: .large)
        let boldSearch = UIImage(systemName: "airplayaudio", withConfiguration: boldConfig)

        button.setImage(boldSearch, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.tintColor = .secondarySystemBackground
        button.addTarget(self, action: #selector(self.showAirPlayMenu(_:)), for: .touchUpInside)

        self.view.addSubview(button)
    }

    @objc private func showAirPlayMenu(_ sender: UIButton){ // copied from https://stackoverflow.com/a/44909445/7974174
        let rect = CGRect(x: 0, y: 0, width: 0, height: 0)
        let airplayVolume = MPVolumeView(frame: rect)
        airplayVolume.showsVolumeSlider = false
        self.view.addSubview(airplayVolume)
        for view: UIView in airplayVolume.subviews {
            if let button = view as? UIButton {
                button.sendActions(for: .touchUpInside)
                break
            }
        }
        airplayVolume.removeFromSuperview()
    }
}
