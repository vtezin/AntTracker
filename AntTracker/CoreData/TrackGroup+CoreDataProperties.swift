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

    @NSManaged public var id: UUID?
    @NSManaged public var title: String
    @NSManaged public var info: String?
    @NSManaged public var track: NSSet?
    @NSManaged public var dateOfLastChange: Date
    @NSManaged public var imageSymbol: String?
    
    public var tracksArray: [Track] {
        let set = track as? Set<Track> ?? []
        return set.sorted {
            $0.wrappedStartDate < $1.wrappedFinishDate
        }
    }
    
    public var wrappedImageSymbol: String {
        
        if let imageSymbol = imageSymbol {
            return imageSymbol
        } else {
            return SFSymbolsAPI.groupDefaultImageSymbol
        }
        
    }
    
    public var wrappedInfo: String {
        return info ?? ""
    }
    
}

extension TrackGroup : Identifiable {

}
