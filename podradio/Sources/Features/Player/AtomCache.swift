import Foundation

class AtomCache {
    private struct CurrentAtomCacheEntry {
        let atom: StreamAtom
        let includedSeasons: [String]?
    }

    private let generator: AtomGenerator
    private var currentAtomCache: CurrentAtomCacheEntry?
    private var nextAtomCache: [StreamAtom: StreamAtom] = [:]
    private var previousAtomCache: [StreamAtom: StreamAtom] = [:]

    init(generator: AtomGenerator) {
        self.generator = generator
    }

    func clear() {
        currentAtomCache = nil
        nextAtomCache = [:]
        previousAtomCache = [:]
    }

    func setCurrentAtom(_ atom: StreamAtom, filter: SeasonFilter?) {
        self.currentAtomCache = CurrentAtomCacheEntry(atom: atom, includedSeasons: filter?.includedSeasons)
    }

    func currentAtom(for filter: SeasonFilter?) -> StreamAtom? {
        guard let currentAtomCache else { return nil }
        guard filter?.includedSeasons == currentAtomCache.includedSeasons else { return nil }

        let now = Date()
        if now >= currentAtomCache.atom.endTime {
            self.currentAtomCache = nil
            return nil
        }

        return currentAtomCache.atom
    }

    func atom(after atom: StreamAtom) -> StreamAtom {
        if let cached = nextAtomCache[atom] {
            return cached
        }

        let next = generator.nextAtom(after: atom)
        nextAtomCache[atom] = next
        previousAtomCache[next] = atom
        return next
    }

    func atom(before atom: StreamAtom) -> StreamAtom {
        if let cached = previousAtomCache[atom] {
            return cached
        }

        let previous = generator.previousAtom(before: atom)
        previousAtomCache[atom] = previous
        nextAtomCache[previous] = atom
        return previous
    }
}
