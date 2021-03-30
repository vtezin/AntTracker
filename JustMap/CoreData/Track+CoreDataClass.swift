//
//  Track+CoreDataClass.swift
//  JustMap
//
//  Created by test on 25.03.2021.
//
//

import Foundation
import CoreData

@objc(Track)
public class Track: NSManagedObject {
    
    static func deleteTrack(track: Track, moc: NSManagedObjectContext) {
        
        track.deleteAllPoints(moc: moc)
        moc.delete(track)
        try? moc.save()
        
    }
    
    func deleteAllPoints(moc: NSManagedObjectContext) {
        
        for point in trackPointsArray {
            moc.delete(point)
        }
        try? moc.save()
        
    }
    
}
