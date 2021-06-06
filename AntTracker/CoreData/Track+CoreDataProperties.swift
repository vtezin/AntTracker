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
    @NSManaged public var trackGroup: TrackGroup?
    
    public var trackPointsArray: [TrackPoint] {
        let set = trackPoint as? Set<TrackPoint> ?? []
        return set.sorted {
            $0.timestamp < $1.timestamp
        }
    }
    
    var durationString: String {
        
        if trackPointsArray.count == 0 {
            return "-"
        }
        
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.allowedUnits = [.second, .minute, .hour, .day]
        dateComponentsFormatter.unitsStyle = .abbreviated
        return dateComponentsFormatter.string(from: startDate, to: finishDate) ?? "-"
        
    }
    
//    var maxSpeed: CLLocationSpeed {
//        
//        if let maxSpeedPoint = trackPointsArray.max(by: { a, b in a.speed < b.speed}) {
//            return maxSpeedPoint.speed
//        }
//        return 0
//    }
//    
//    var averageSpeed: CLLocationSpeed {
//        
//        if trackPointsArray.count == 0 {
//            return 0
//        }
//        
//        var speedSumm: Double = 0
//        for trackPoint in trackPointsArray {
//            speedSumm += trackPoint.speed
//        }
//        
//        return speedSumm / Double(trackPointsArray.count)
//        
//    }
//    
//    var maxAltitude: Int {
//        
//        if let altPoint = trackPointsArray.max(by: { a, b in a.altitude < b.altitude}) {
//            return Int(altPoint.altitude)
//        }
//        return 0
//        
//    }
//    
//    var minAltitude: Int {
//        
//        if let altPoint = trackPointsArray.min(by: { a, b in a.altitude < b.altitude}) {
//            return Int(altPoint.altitude)
//        }
//        return 0
//        
//    }
    
    var totalDistanceMeters: CLLocationDistance {
        return CLLocationDistance(totalDistance)
    }
    
    
}

extension Track : Identifiable {

}
