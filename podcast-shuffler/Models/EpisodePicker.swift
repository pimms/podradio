import Foundation
import SwiftUI

// MARK: - Utilities

fileprivate struct Settings {
    @AppStorage(StorageKey.useBingeEpisodePicker.rawValue)
    var useBingePicker = false
}

fileprivate var globalPickers: [Feed.ID: EpisodePicker] = [:]

// MARK: - EpisodePicker

protocol EpisodePicker {
    var feed: Feed { get }
    func currentStreamable() -> Streamable
}


func episodePicker(for feed: Feed) -> EpisodePicker {
    if let picker = globalPickers[feed.id] {
        return picker
    }

    let picker: EpisodePicker
    if Settings().useBingePicker {
        picker = BingeEpisodePicker()
    } else {
        let filter = FilterStore.shared.filter(for: feed)
        picker = DefaultEpisodePicker(filter: filter)
    }

    globalPickers[feed.id] = picker
    return picker
}

