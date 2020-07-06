import Foundation

private struct StreamableImpl: Streamable {
    let episode: Episode
    var nextStreamable: Streamable { picker.streamable(after: self) }
    var previousStreamable: Streamable{ picker.streamable(before: self) }

    private let picker: EpisodePicker

    init(episode: Episode, picker: EpisodePicker) {
        self.episode = episode
        self.picker = picker
    }
}

class EpisodePicker {
    private let feed: Feed

    init?(feed: Feed) {
        guard !feed.episodes.isEmpty else { return nil }
        self.feed = feed
    }

    // MARK: - Internal methods

    func currentStreamable() -> Streamable {
        /// TODO:
        /// - Figure out the actual length of the episodes (backend task)
        /// - Make the StreamPoint for any given time deterministic and consistent

        // Make the current StreamPoint consistent on an hour-by-hour-basis
        // at the very least. Do this by seeding with the current hour.
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH"
        let seedString = formatter.string(from: Date())
        var rng = randomNumberGenerator(from: seedString)
        return streamable(using: &rng)
    }

    // MARK: - Fileprivate methods

    fileprivate func streamable(after current: Streamable) -> Streamable {
        let seedString = "after-\(current.episode.id)"
        var rng = randomNumberGenerator(from: seedString)
        return streamable(using: &rng)
    }

    fileprivate func streamable(before current: Streamable) -> Streamable {
        let seedString = "before-\(current.episode.id)"
        var rng = randomNumberGenerator(from: seedString)
        return streamable(using: &rng)
    }

    // MARK: - Private methods

    private func randomNumberGenerator(from seedString: String) -> RandomNumberGenerator {
        guard let data = seedString.data(using: .utf8) else { fatalError() }
        let seed = [UInt8](data)
        return ARC4RandomNumberGenerator(seed: seed)
    }

    private func streamable(using rng: inout RandomNumberGenerator) -> Streamable {
        let index = rng.next() % UInt64(feed.episodes.count)
        let episode = feed.episodes[Int(index)]
        return StreamableImpl(episode: episode, picker: self)
    }
}

