import Foundation

class StreamSchedule {
    private let feed: Feed

    init(feed: Feed) {
        self.feed = feed
    }

    // MARK: - Internal methods

    func currentAtom() -> StreamAtom {
        let currentPeriodStart = currentPeriodStartTime()

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let seedString = formatter.string(from: currentPeriodStart)
        var rng = randomNumberGenerator(from: seedString)
        var atom = makeAtom(using: &rng, startTime: currentPeriodStart)

        let now = Date()
        while atom.endTime.distance(to: now) > 15 {
            atom = atom.nextAtom
        }

        return atom
    }

    func streamable(after current: StreamAtom) -> StreamAtom {
        let seedString = "after-\(current.episode.url!.hashValue)"
        var rng = randomNumberGenerator(from: seedString)
        return makeAtom(using: &rng, startTime: current.endTime)
    }

    func streamable(before current: StreamAtom) -> StreamAtom {
        let seedString = "before-\(current.episode.url!.hashValue)"
        var rng = randomNumberGenerator(from: seedString)
        return makeAtom(using: &rng, endingAt: current.endTime)
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
        return StreamAtom(schedule: self, episode: episode, startTime: startTime)
    }

    private func makeAtom(using rng: inout RandomNumberGenerator, endingAt endTime: Date) -> StreamAtom {
        let filteredEpisodes = filteredEpisodes()
        let index = rng.next() % UInt64(filteredEpisodes.count)
        let episode = filteredEpisodes[Int(index)]

        let startTime = endTime.addingTimeInterval(-episode.duration)
        return StreamAtom(schedule: self, episode: episode, startTime: startTime)
    }

    private func currentPeriodStartTime() -> Date {
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

    private func filteredEpisodes() -> [Episode] {
        var episodes = [Episode]()

        for season in feed.seasons!.allObjects {
            guard let season = season as? Season else { continue }
            guard shouldIncludeSeason(season) else { continue }

            episodes.append(contentsOf: season.episodes!.allObjects.compactMap({ $0 as? Episode }))
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