import Foundation
import CoreData

extension Episode {
    var year: Int {
        let comps = Calendar.current.dateComponents([.year], from: publishDate!)
        return comps.year!
    }
}
