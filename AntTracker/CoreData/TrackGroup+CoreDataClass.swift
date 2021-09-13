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

    static func addUpdateGroup(group: TrackGroup?,
                               moc: NSManagedObjectContext,
                               title: String,
                               info: String,
                               imageSymbol: String
                               ) {
        
        var groupForSave: TrackGroup
        
        if group == nil {
            groupForSave = TrackGroup(context: moc)
            groupForSave.id = UUID()
        } else {
            groupForSave = group!
        }
        
        groupForSave.dateOfLastChange = Date()
        groupForSave.title = title
        groupForSave.info = info
        groupForSave.imageSymbol = imageSymbol
        
        try? moc.save()
        
    }
    
    private func prepareForDelete(moc: NSManagedObjectContext) {
        
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
    
}

