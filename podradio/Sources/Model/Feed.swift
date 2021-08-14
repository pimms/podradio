import Foundation
import CoreData

@objc(Feed)
class Feed: NSManagedObject {

}

extension Feed: Identifiable {
    var id: Int { url.hashValue }
}

extension Feed {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Feed> {
        return NSFetchRequest<Feed>(entityName: "Feed")
    }

    @NSManaged var title: String!
    @NSManaged var url: URL!
    @NSManaged var imageUrl: URL?
    @NSManaged var lastRefresh: Date!
    @NSManaged var episodes: NSSet?
}

// MARK: Generated accessors for episodes
extension Feed {
    @objc(addEpisodesObject:)
    @NSManaged func addToEpisodes(_ value: Episode)

    @objc(removeEpisodesObject:)
    @NSManaged func removeFromEpisodes(_ value: Episode)

    @objc(addEpisodes:)
    @NSManaged func addToEpisodes(_ values: NSSet)

    @objc(removeEpisodes:)
    @NSManaged func removeFromEpisodes(_ values: NSSet)
}
