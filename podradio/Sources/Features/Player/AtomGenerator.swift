import Foundation

class AtomGenerator {
    private var feed: Feed
    private lazy var cache = AtomCache(generator: self)

    init(feed: Feed) {
        self.feed = feed
    }

    // MARK: - Internal methods

    func updateFeed(_ feed: Feed) {
        guard feed.isSameFeed(as: self.feed) else { fatalError() }
        self.feed = feed
        self.cache.clear()
    }

    func currentAtom() -> StreamAtom {
        if let cached = cache.currentAtom(for: feed.filter) {
            return cached
        }

        let currentPeriodStart = currentPeriodStartTime()

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let seedString = formatter.string(from: currentPeriodStart)
        var rng = randomNumberGenerator(from: seedString)
        var atom = makeAtom(using: &rng, startTime: currentPeriodStart)

        let now = Date()
        while atom.endTime.distance(to: now) > 0 {
            atom = nextAtom(after: atom)
        }

        cache.setCurrentAtom(atom, filter: feed.filter)
        return atom
    }

    func nextAtom(after current: StreamAtom) -> StreamAtom {
        if let cached = cache.atom(after: current) {
            return cached
        }

        let seedString = "after-\(current.episode.url!.absoluteString)"
        var rng = randomNumberGenerator(from: seedString)
        let atom = makeAtom(using: &rng, startTime: current.endTime)
        cache.cacheAtom(atom, after: current)
        return atom
    }

    func previousAtom(before current: StreamAtom) -> StreamAtom {
        if let cached = cache.atom(before: current) {
            return cached
        }

        fatalError("⚠️⚠️⚠️ Cache miss when traversing the cache backwards ⚠️⚠️⚠️")
    }

    func currentPeriodStartTime() -> Date {
        // Each "streamable" day starts at 05:00 in the local timezone.
        let calendar = Calendar.current
        let todayStart = calendar.date(bySettingHour: 5, minute: 0, second: 0, of: Date())!

        let currentPeriodStart: Date
        if calendar.dateComponents([.hour], from: Date()).hour! <= 5 {
            currentPeriodStart = calendar.date(byAdding: .day, value: -1, to: todayStart)!
        } else {
            currentPeriodStart = todayStart
        }

        return currentPeriodStart
    }

    func currentPeriodEndTime() -> Date {
        let startTime = currentPeriodStartTime()

        // https://gist.github.com/timvisee/fcda9bbdff88d45cc9061606b4b923ca
        return startTime.addingTimeInterval(86400)
    }

    // MARK: - Private methods

    private func randomNumberGenerator(from seedString: String) -> RandomNumberGenerator {
        guard let data = seedString.data(using: .utf8) else { fatalError() }
        let seed = [UInt8](data)
        return ARC4RandomNumberGenerator(seed: seed)
    }

    private func makeAtom(using rng: inout RandomNumberGenerator, startTime: Date) -> StreamAtom {
        let filteredEpisodes = filteredEpisodes()
        let index = rng.next() % UInt64(filteredEpisodes.count)
        let episode = filteredEpisodes[Int(index)]
        return StreamAtom(episode: episode, startTime: startTime)
    }

    private func makeAtom(using rng: inout RandomNumberGenerator, endingAt endTime: Date) -> StreamAtom {
        let filteredEpisodes = filteredEpisodes()
        let index = rng.next() % UInt64(filteredEpisodes.count)
        let episode = filteredEpisodes[Int(index)]

        let startTime = endTime.addingTimeInterval(-episode.duration)
        return StreamAtom(episode: episode, startTime: startTime)
    }

    private func filteredEpisodes() -> [Episode] {
        var episodes = [Episode]()

        for season in feed.sortedSeasons {
            guard shouldIncludeSeason(season) else { continue }
            episodes.append(contentsOf: season.sortedEpisodes)
        }

        return episodes
    }

    private func shouldIncludeSeason(_ season: Season) -> Bool {
        if let includedSeasons = feed.filter?.includedSeasons {
            return includedSeasons.contains(season.name!)
        }
        return true
    }

}
