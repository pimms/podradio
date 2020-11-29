import Foundation
import UIKit
import MediaPlayer
import SwiftUI

struct AirPlayButton: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<AirPlayButton>) -> UIViewController {
        return AirPlayViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<AirPlayButton>) {}
}

fileprivate class AirPlayViewController: UIViewController {

    private lazy var button: UIButton = {
        let boldConfig = UIImage.SymbolConfiguration(scale: .large)
        let boldSearch = UIImage(systemName: "airplayaudio", withConfiguration: boldConfig)

        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(boldSearch, for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: #selector(self.showAirPlayMenu(_:)), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            button.topAnchor.constraint(equalTo: view.topAnchor),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            button.widthAnchor.constraint(equalToConstant: 40),
            button.heightAnchor.constraint(equalToConstant: 40),
        ])
    }

    @objc private func showAirPlayMenu(_ sender: UIButton){ // copied from https://stackoverflow.com/a/44909445/7974174
        let airplayVolume = MPVolumeView(frame: .zero)
        airplayVolume.showsVolumeSlider = false
        view.addSubview(airplayVolume)
        for view: UIView in airplayVolume.subviews {
            if let button = view as? UIButton {
                button.sendActions(for: .touchUpInside)
                break
            }
        }
        airplayVolume.removeFromSuperview()
    }
}

