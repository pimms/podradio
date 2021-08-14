import Foundation
import CoreData

@objc(Episode)
class Episode: NSManagedObject {

}

extension Episode: Identifiable {
    var id: Int { url.hashValue }
}

extension Episode {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Episode> {
        return NSFetchRequest<Episode>(entityName: "Episode")
    }

    @NSManaged var url: URL!
    @NSManaged var title: String!
    @NSManaged var detailedDescription: String?
    @NSManaged var duration: Double
    @NSManaged var publishDate: Date!
    @NSManaged var feed: Feed?
}
