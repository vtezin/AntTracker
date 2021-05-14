//
//  Track+CoreDataProperties.swift
//  JustMap
//
//  Created by test on 25.03.2021.
//
//

import Foundation
import CoreData


extension Track {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Track> {
        return NSFetchRequest<Track>(entityName: "Track")
    }

    @NSManaged public var color: String
    @NSManaged public var finishDate: Date
    @NSManaged public var id: UUID?
    @NSManaged public var info: String
    @NSManaged public var title: String
    @NSManaged public var showOnMap: Bool
    @NSManaged public var startDate: Date
    @NSManaged public var totalDistance: Int64
    @NSManaged public var region: String
    @NSManaged public var trackAnnotationPoint: NSSet?
    @NSManaged public var trackPoint: NSSet?
    
    public var trackPointsArray: [TrackPoint] {
        let set = trackPoint as? Set<TrackPoint> ?? []
        return set.sorted {
            $0.timestamp < $1.timestamp
        }
    }
    
}

extension Track : Identifiable {

}
