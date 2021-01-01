import Foundation

private struct StreamableImpl: Streamable {
    private let picker: BingeEpisodePicker

    init(episode: Episode, startTime: Date, picker: BingeEpisodePicker) {
        self.episode = episode
        self.startTime = startTime
        self.picker = picker
    }

    let episode: Episode
    let startTime: Date

    var nextStreamable: Streamable {
        picker.streamable(after: self)
    }

    var previousStreamable: Streamable {
        picker.streamable(before: self)
    }
}

class BingeEpisodePicker: EpisodePicker {
    let feed = Feed(episodes: [], title: "BingeFeed", imageUrl: nil, url: URL(string: "https://stienjoa.kim")!)

    func currentStreamable() -> Streamable {
        return streamable(atTime: Date().timeIntervalSince1970)
    }

    func setFilter(_ filter: Filter) { }

    fileprivate func streamable(after item: Streamable) -> Streamable {
        return streamable(atTime: item.endTime.timeIntervalSince1970 + 1)
    }

    fileprivate func streamable(before item: Streamable) -> Streamable {
        return streamable(atTime: item.startTime.timeIntervalSince1970 - 1)
    }

    private func streamable(atTime time: TimeInterval) -> Streamable {
        let intTime = Int(time) - Int(time) % 10
        let startTime = Date(timeIntervalSince1970: TimeInterval(intTime))

        let episode = Episode(
                url: URL(string: "https://www2.cs.uic.edu/~i101/SoundFiles/gettysburg10.wav")!,
                title: "Binge Episode",
                description: "Binge test.\n\(intTime)",
                duration: 10,
                date: startTime)
        return StreamableImpl(episode: episode, startTime: startTime, picker: self)
    }
}
