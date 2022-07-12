import Foundation

class CurrentTimeReporter: ObservableObject {

    // MARK: - Internal properties

    var atom: StreamAtom? = nil

    var onUpdateTime: ((TimeInterval) -> Void)?
    var onAtomCompleted: (() -> Void)?

    // MARK: - Private properties

    private var timer: Timer? = nil

    // MARK: - Setup

    init() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
            guard let atom = self?.atom else { return }

            let currentPosition = atom.currentPosition
            if currentPosition >= atom.duration {
                self?.onAtomCompleted?()
            } else {
                self?.onUpdateTime?(currentPosition)
            }
        })
    }
}
