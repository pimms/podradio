import Foundation

private struct StreamableImpl: Streamable {
    let episode: Episode
    var nextStreamable: Streamable { picker.streamable(after: self) }
    var previousStreamable: Streamable{ picker.streamable(before: self) }
    var startTime: Date

    private let picker: EpisodePicker

    init(episode: Episode, picker: EpisodePicker, startTime: Date) {
        self.episode = episode
        self.picker = picker
        self.startTime = startTime
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
        let currentPeriodStart = currentPeriodStartTime()

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH"

        let seedString = formatter.string(from: currentPeriodStart)
        var rng = randomNumberGenerator(from: seedString)
        var streamable = makeStreamable(using: &rng, startTime: currentPeriodStart)

        let now = Date()
        while streamable.endTime.distance(to: now) > 0 {
            streamable = streamable.nextStreamable
        }

        return streamable
    }

    // MARK: - Fileprivate methods

    fileprivate func streamable(after current: Streamable) -> Streamable {
        let seedString = "after-\(current.episode.id)"
        var rng = randomNumberGenerator(from: seedString)
        return makeStreamable(using: &rng, startTime: current.endTime)
    }

    fileprivate func streamable(before current: Streamable) -> Streamable {
        let seedString = "before-\(current.episode.id)"
        var rng = randomNumberGenerator(from: seedString)
        return makeStreamable(using: &rng, endingAt: current.endTime)
    }

    // MARK: - Private methods

    private func randomNumberGenerator(from seedString: String) -> RandomNumberGenerator {
        guard let data = seedString.data(using: .utf8) else { fatalError() }
        let seed = [UInt8](data)
        return ARC4RandomNumberGenerator(seed: seed)
    }

    private func makeStreamable(using rng: inout RandomNumberGenerator, startTime: Date) -> Streamable {
        let index = rng.next() % UInt64(feed.episodes.count)
        let episode = feed.episodes[Int(index)]
        return StreamableImpl(episode: episode, picker: self, startTime: startTime)
    }

    private func makeStreamable(using rng: inout RandomNumberGenerator, endingAt endTime: Date) -> Streamable {
        let index = rng.next() % UInt64(feed.episodes.count)
        let episode = feed.episodes[Int(index)]

        let startTime = endTime.addingTimeInterval(-episode.duration)
        return StreamableImpl(episode: episode, picker: self, startTime: startTime)
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
}

