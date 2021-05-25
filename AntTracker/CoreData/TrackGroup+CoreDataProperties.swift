//
//  TrackGroup+CoreDataProperties.swift
//  AntTracker
//
//  Created by test on 24.05.2021.
//
//

import Foundation
import CoreData


extension TrackGroup {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackGroup> {
        return NSFetchRequest<TrackGroup>(entityName: "TrackGroup")
    }

    @NSManaged public var title: String
    @NSManaged public var id: UUID
    @NSManaged public var track: NSSet?
    @NSManaged public var positionInList: Int16

    public var tracksArray: [Track] {
        let set = track as? Set<Track> ?? []
        return set.sorted {
            $0.startDate < $1.startDate
        }
    }
    
}

extension TrackGroup : Identifiable {

}
