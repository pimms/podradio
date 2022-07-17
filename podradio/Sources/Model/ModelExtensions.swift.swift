import Foundation
import CoreData

extension Episode {
    var year: Int {
        let comps = Calendar.current.dateComponents([.year], from: publishDate!)
        return comps.year!
    }
}

extension Feed {
    var sortedSeasons: [Season] {
        seasons!
            .sortedArray(using: [.init(key: #keyPath(Season.uniqueId), ascending: true)])
            .compactMap({ $0 as? Season })
    }
}

extension Season {
    var sortedEpisodes: [Episode] {
        episodes!
            .sortedArray(using: [.init(key: #keyPath(Episode.publishDate), ascending: true)])
            .compactMap({ $0 as? Episode })
    }
}

extension Season {

}
