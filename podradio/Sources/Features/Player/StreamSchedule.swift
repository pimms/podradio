import Foundation
import Combine

class StreamSchedule: ObservableObject, Equatable {

    // MARK: - Static

    static func == (lhs: StreamSchedule, rhs: StreamSchedule) -> Bool {
        return lhs.feed == rhs.feed
    }

    // MARK: - Internal properties

    @Published var currentTime: TimeInterval = 0
    @Published var atomDuration: TimeInterval = 1
    @Published var atom: StreamAtom {
        didSet {
            atomDuration = atom.duration
            timeReporter.atom = atom
        }
    }
    @Published var todaysSchedule: [StreamAtom] = []

    private(set) var feed: Feed

    // MARK: - Private properties

    private let generator: AtomGenerator
    private let timeReporter: CurrentTimeReporter
    private var feedFilterSubscription: AnyCancellable?

    // MARK: - Init

    init(feed: Feed) {
        self.feed = feed
        self.generator = AtomGenerator(feed: feed)
        self.atom = generator.currentAtom()
        self.timeReporter = CurrentTimeReporter()
        self.atomDuration = self.atom.duration

        timeReporter.atom = self.atom
        timeReporter.onAtomCompleted = { [weak self] in
            guard let self else { return }
            print("⏰ \(feed.title!): atom completed")
            self.atom = self.generator.currentAtom()
            self.atomDuration = self.atom.duration
            self.currentTime = 0
        }

        timeReporter.onUpdateTime = { [weak self] currentTime in
            self?.currentTime = currentTime
        }

        rebuildTodaysSchedule()
    }

    // MARK: - Internal methods

    func updateFeed(_ feed: Feed) {
        guard feed.url! == self.feed.url! else { fatalError() }
        self.feed = feed

        generator.updateFeed(feed)
        atom = generator.currentAtom()
        timeReporter.atom = atom
        atomDuration = atom.duration
        currentTime = 0
        rebuildTodaysSchedule()
    }

    // MARK: - Private methods

    private func filterReloaded() {
        self.atom = generator.currentAtom()
        self.currentTime = self.atom.currentPosition
    }

    private func rebuildTodaysSchedule() {
        let current = generator.currentAtom()

        let startTime = generator.currentPeriodStartTime()
        let endTime = generator.currentPeriodEndTime()

        var first: StreamAtom = current
        while first.startTime > startTime {
            first = generator.previousAtom(before: first)
        }

        var last: StreamAtom = current
        while last.startTime < endTime && last.endTime < endTime {
            last = generator.nextAtom(after: last)
        }

        // TODO: IT SEEMS LIKE THE DOUBLY LINKED LIST IS NOT VERY
        // DETERMINISTIC. THAT IS A PROBLEM.
        var index: [StreamAtom] = []
        var iterator = first
        while iterator != last {
            index.append(iterator)
            iterator = generator.nextAtom(after: iterator)
        }
        index.append(iterator)
        todaysSchedule = index
    }
}
