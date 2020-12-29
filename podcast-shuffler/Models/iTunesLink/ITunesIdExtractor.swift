import Foundation

class ITunesIdExtractor {
    func extractId(from url: URL) -> String? {
        guard url.host == "podcasts.apple.com" else { return nil }
        guard let pathComponent = url.pathComponents.last else { return nil }
        guard let regex = try? NSRegularExpression(pattern: "id[0-9]{8,}") else { return nil }

        let range = NSRange(location: 0, length: pathComponent.utf16.count)
        guard regex.firstMatch(in: pathComponent, options: [], range: range) != nil else { return nil }

        let idString = pathComponent.suffix(from: pathComponent.index(pathComponent.startIndex, offsetBy: 2))
        return String(idString)
    }
}
