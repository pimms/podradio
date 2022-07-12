import Foundation
import AVFoundation
import ModernAVPlayer
import MediaPlayer

class EpisodePlayer: ObservableObject {
    static var current: EpisodePlayer?

    enum State {
        case playing
        case buffering
        case paused
        case error
    }

    // MARK: - Published properties

    @Published var currentEpisode: Episode?
    @Published var state: State = .paused
    @Published var duration: TimeInterval = 0
    @Published var currentTime: TimeInterval = 0

    // MARK: - Internal properties

    var feed: Feed? { episodePicker?.feed }

    // MARK: - Private properties

    private lazy var log = Log(self)
    private let player: ModernAVPlayer
    private var episodePicker: EpisodePicker?
    private var streamable: Streamable?
    private var timer: Timer? { willSet { timer?.invalidate() } }

    private var isTransitioningToNextEpisode = false
    private var playRequested = false

    private var isCurrent: Bool { Self.current === self }

    // MARK: - Lifecycle

    init() {
        let config = CustomPlayerConfiguration()
        player = ModernAVPlayer(config: config, loggerDomains: [.error, .unavailableCommand, .remoteCommand])
        player.remoteCommands = [ makePlayCommand(), makeStopCommand(), makePlayPauseCommand() ]
        player.delegate = self
        startSimulatedProgressTimer()
    }

    // MARK: - Internal methods

    func configure(with picker: EpisodePicker) {
        self.episodePicker = picker
        let streamable = picker.currentStreamable()
        configure(with: streamable)
    }

    func pause() {
        playRequested = false
        player.pause()
    }

    func play() {
        guard let streamable = streamable else { fatalError("No streamable") }

        playRequested = true
        becomeCurrent()

        let position = streamable.startTime.distance(to: Date())
        log.debug("Playing from position \(position)")

        player.seek(position: position)
        player.play()
    }

    // MARK: - Private methods

    private func configure(with streamable: Streamable) {
        setStreamable(streamable)

        let url = streamable.episode.url
        let media = ModernAVPlayerMedia(url: url, type: .stream(isLive: true))

        let position = streamable.startTime.distance(to: Date())
        player.load(media: media, autostart: false, position: position)
        log.info("Loading episode: \(url.absoluteString) at position \(position)")
    }

    private func setStreamable(_ streamable: Streamable) {
        self.streamable = streamable
        DispatchQueue.syncOnMain {
            self.currentEpisode = streamable.episode
        }
    }

    private func becomeCurrent() {
        if !isCurrent {
            Self.current?.resignCurrent()
            Self.current = self
        }
    }

    private func resignCurrent() {
        pause()
    }

    private func makeMetadata() -> ModernAVPlayerMediaMetadata? {
        guard let episode = streamable?.episode else { return nil }
        guard let feed = episodePicker?.feed else { return nil }

        var albumTitle: String?
        if let year = Calendar.current.dateComponents([.year], from: episode.date).year {
            albumTitle = "\(year)"
        }

        return ModernAVPlayerMediaMetadata(title: episode.title,
                                           albumTitle: albumTitle,
                                           artist: feed.title,
                                           remoteImageUrl: feed.imageUrl)
    }

    private func makePlayCommand() -> ModernAVPlayerRemoteCommand {
        let command = MPRemoteCommandCenter.shared().playCommand
        let isEnabled: (MediaType) -> Bool = { [weak self] _ in
            self?.isCurrent ?? false
        }

        let handler: (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus = { [weak self] _ in
            guard self?.isCurrent == true else {
                return .noSuchContent
            }

            self?.play()
            return .success
        }

        command.addTarget(handler: handler)
        return ModernAVPlayerRemoteCommand(reference: command, debugDescription: "PodRadio-play", isEnabled: isEnabled)
    }

    private func makePlayPauseCommand() -> ModernAVPlayerRemoteCommand {
        let command = MPRemoteCommandCenter.shared().togglePlayPauseCommand
        let isEnabled: (MediaType) -> Bool = { [weak self] _ in
            self?.isCurrent ?? false
        }

        let handler: (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus = { [weak self] _ in
            guard let self = self, self.isCurrent else { return .noSuchContent }

            switch self.state {
            case .buffering, .playing:
                self.pause()
            case .paused, .error:
                self.play()
            }

            return .success
        }

        command.addTarget(handler: handler)
        return ModernAVPlayerRemoteCommand(reference: command, debugDescription: "PodRadio-togglePlayPause", isEnabled: isEnabled)
    }

    private func makeStopCommand() -> ModernAVPlayerRemoteCommand {
        let command = MPRemoteCommandCenter.shared().stopCommand
        let isEnabled: (MediaType) -> Bool = { [weak self] _ in
            self?.isCurrent ?? false
        }

        let handler: (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus = { [weak self] _ in
            guard self?.isCurrent == true else {
                return .noSuchContent
            }

            self?.pause()
            return .success
        }

        command.addTarget(handler: handler)
        return ModernAVPlayerRemoteCommand(reference: command, debugDescription: "PodRadio-stop", isEnabled: isEnabled)
    }

}

extension EpisodePlayer: ModernAVPlayerDelegate {
    func modernAVPlayer(_ player: ModernAVPlayer, didStateChange state: ModernAVPlayer.State) {
        switch state {
        case .playing:
            player.updateMetadata(makeMetadata())
            self.state = .playing
            self.timer = nil
        case .buffering,
             .initialization,
             .loading,
             .waitingForNetwork:
            self.state = .buffering
            startSimulatedProgressTimer()
        case .loaded,
             .paused,
             .stopped:
            self.state = .paused
            startSimulatedProgressTimer()
        case .failed:
            self.state = .error
            self.playRequested = false
            self.isTransitioningToNextEpisode = false
            self.timer = nil
        }
        log.debug("State changed: \(state)")

        // When an episode ends and we reconfigure the player, autoplay doesn't
        // seem to function properly, so we need to handle the transition ourselves.
        // After loading the next episode, we enter the "stopped" state, from which
        // we can start playing the next episode.
        if state == .stopped, isTransitioningToNextEpisode {
            log.debug("Transitioning to nest episode: playing")
            isTransitioningToNextEpisode = false
            play()
        } else if state == .loaded, playRequested {
            log.debug("Done loading, play requested: playing")
            play()
        }
    }

    func modernAVPlayer(_ player: ModernAVPlayer, didCurrentMediaChange media: PlayerMedia?) {
        log.debug("Current media changed: \(media?.url.absoluteString ?? "<nil>")")
    }

    func modernAVPlayer(_ player: ModernAVPlayer, didCurrentTimeChange currentTime: Double) {
        DispatchQueue.syncOnMain {
            self.currentTime = currentTime
        }
    }

    func modernAVPlayer(_ player: ModernAVPlayer, didItemDurationChange itemDuration: Double?) {
        log.debug("Item duration changed: \(itemDuration ?? -1)")
        DispatchQueue.syncOnMain {
            if let itemDuration = itemDuration {
                self.duration = itemDuration
            } else {
                self.duration = 0
                self.currentTime = 0
            }
        }
    }

    func modernAVPlayer(_ player: ModernAVPlayer, unavailableActionReason: PlayerUnavailableActionReason) {
        log.warn("Unavailable action: \(unavailableActionReason)")
    }

    func modernAVPlayer(_ player: ModernAVPlayer, didItemPlayToEndTime endTime: Double) {
        player.stop()
        if let streamable = streamable {
            isTransitioningToNextEpisode = true
            configure(with: streamable.nextStreamable)
        }
    }
}

// MARK: - Simulated progress

extension EpisodePlayer {
    private func startSimulatedProgressTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.simulatedProgressTick()
        }
        timer?.fire()
    }

    private func simulatedProgressTick() {
        guard let streamable = streamable else { return }

        let now = Date()
        guard streamable.endTime > now else {
            var next = streamable.nextStreamable
            while next.endTime < now {
                next = next.nextStreamable
            }
            setStreamable(next)
            return
        }

        let position = streamable.startTime.distance(to: now)
        let duration = streamable.startTime.distance(to: streamable.endTime)

        DispatchQueue.syncOnMain {
            self.currentTime = position
            self.duration = duration
        }
    }
}
