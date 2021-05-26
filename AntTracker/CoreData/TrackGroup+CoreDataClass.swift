//
//  TrackGroup+CoreDataClass.swift
//  AntTracker
//
//  Created by test on 24.05.2021.
//
//

import Foundation
import CoreData

@objc(TrackGroup)
public class TrackGroup: NSManagedObject {

    func prepareForDelete(moc: NSManagedObjectContext) {
        
        for track in tracksArray {
            track.trackGroup = nil
        }
        try? moc.save()
        
    }
    
    static func deleteGroup(group: TrackGroup, moc: NSManagedObjectContext) {
        
        group.prepareForDelete(moc: moc)
        moc.delete(group)
        try? moc.save()
        
    }
    
    func updateDateOfLastChange(moc: NSManagedObjectContext) {
        dateOfLastChange = Date()
    }
    
}

