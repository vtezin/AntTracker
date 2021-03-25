//
//  TrackPoint+CoreDataProperties.swift
//  JustMap
//
//  Created by test on 25.03.2021.
//
//

import Foundation
import CoreData


extension TrackPoint {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackPoint> {
        return NSFetchRequest<TrackPoint>(entityName: "TrackPoint")
    }

    @NSManaged public var altitude: Double
    @NSManaged public var horizontalAccuracy: Double
    @NSManaged public var id: UUID
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var timestamp: Date
    @NSManaged public var verticalAccuracy: Double
    @NSManaged public var track: Track

}

extension TrackPoint : Identifiable {

}
