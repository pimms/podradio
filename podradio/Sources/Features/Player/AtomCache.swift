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

    func atom(after atom: StreamAtom) -> StreamAtom? {
        if let cached = nextAtomCache[atom] {
            return cached
        } else {
            return nil
        }
    }

    func cacheAtom(_ next: StreamAtom, after current: StreamAtom) {
        nextAtomCache[current] = next
        previousAtomCache[next] = current
    }

    func atom(before atom: StreamAtom) -> StreamAtom? {
        if let cached = previousAtomCache[atom] {
            return cached
        } else {
            return nil
        }
    }

    func cacheAtom(_ previous: StreamAtom, before current: StreamAtom) {
        previousAtomCache[current] = previous
        nextAtomCache[previous] = current
    }
}
