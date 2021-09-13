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

    @NSManaged public var color: String?
    @NSManaged public var id: UUID?
    @NSManaged public var info: String?
    @NSManaged public var locationString: String?
    @NSManaged public var title: String?
    @NSManaged public var startDate: Date?
    @NSManaged public var finishDate: Date?
    @NSManaged public var totalDistance: Int64
    @NSManaged public var trackAnnotationPoint: NSSet?
    @NSManaged public var trackPoint: NSSet?
    @NSManaged public var trackGroup: TrackGroup?
    
    public var wrappedColor: String {
        
        if let color = color {
            return color
        } else {
            return AppConstants.defaultColor.description
        }
        
    }
    
    public var wrappedInfo: String {
        return info ?? ""
    }
    
    public var wrappedTitle: String {
        return title ?? ""
    }
    
    public var wrappedLocationString: String {
        return locationString ?? ""
    }
    
    public var wrappedStartDate: Date {
        return startDate ?? Date.smallestDate
    }
    
    public var wrappedFinishDate: Date {
        return finishDate ?? Date.smallestDate
    }
    
    public var trackPointsArray: [TrackPoint] {
        let set = trackPoint as? Set<TrackPoint> ?? []
        return set.sorted {
            $0.timestamp < $1.timestamp
        }
    }
    
    func getTrackPointsAsArray() -> [TrackPoint] {
        let set = trackPoint as? Set<TrackPoint> ?? []
        
        return set.sorted {
            $0.timestamp < $1.timestamp
        }
        
    }
    
    func getTrackPointsArrayFromCoreData(moc: NSManagedObjectContext) -> [TrackPoint]  {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackPoint")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TrackPoint.timestamp, ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "track == %@", self)
            
        let result = try? moc.fetch(fetchRequest)
        
        var arrayForReturn = [TrackPoint]()
        
        for pointCD in result! {
            arrayForReturn.append(pointCD as! TrackPoint)
        }
        
        return arrayForReturn
        
    }
    
    var durationString: String {
        
        if trackPointsArray.count == 0 {
            return "-"
        }
        
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.allowedUnits = [.second, .minute, .hour, .day]
        dateComponentsFormatter.unitsStyle = .abbreviated
        return dateComponentsFormatter.string(from: wrappedStartDate,
                                              to: wrappedFinishDate) ?? "-"
        
    }    
    
    var totalDistanceMeters: CLLocationDistance {
        return CLLocationDistance(totalDistance)
    }
    
    
    
}

extension Track : Identifiable {

}
