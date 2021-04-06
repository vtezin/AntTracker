//
//  TrackAnnotationPoint+CoreDataProperties.swift
//  JustMap
//
//  Created by test on 25.03.2021.
//
//

import Foundation
import CoreData


extension TrackAnnotationPoint {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackAnnotationPoint> {
        return NSFetchRequest<TrackAnnotationPoint>(entityName: "TrackAnnotationPoint")
    }

    @NSManaged public var altitude: Double
    @NSManaged public var color: String
    @NSManaged public var id: UUID
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var subtittle: String
    @NSManaged public var tittle: String
    @NSManaged public var track: Track

}

extension TrackAnnotationPoint : Identifiable {

}
