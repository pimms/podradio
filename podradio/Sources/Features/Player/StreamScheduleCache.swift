import Foundation

class StreamScheduleCache {
    private var atom: StreamAtom?

    func setCurrentAtom(_ atom: StreamAtom) {
        self.atom = atom
    }

    func currentAtom() -> StreamAtom? {
        guard let atom else { return nil }

        let now = Date()
        if now >= atom.endTime {
            self.atom = nil
            return nil
        }

        return atom
    }
}
