import Foundation

class StreamScheduleCache {
    private struct Entry {
        let atom: StreamAtom
        let includedSeasons: [String]?
    }
    private var entry: Entry?

    func clear() {
        entry = nil
    }

    func setCurrentAtom(_ atom: StreamAtom, filter: SeasonFilter?) {
        self.entry = Entry(atom: atom, includedSeasons: filter?.includedSeasons)
    }

    func currentAtom(for filter: SeasonFilter?) -> StreamAtom? {
        guard let entry else { return nil }
        guard filter?.includedSeasons == entry.includedSeasons else { return nil }

        let now = Date()
        if now >= entry.atom.endTime {
            self.entry = nil
            return nil
        }

        return entry.atom
    }
}
