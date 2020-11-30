import Foundation

enum StorageKey: String {
    case useBingeEpisodePicker

    var rawValue: String {
        "appstorage.\(self)"
    }
}
