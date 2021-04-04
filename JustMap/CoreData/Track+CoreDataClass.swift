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
    
    func geoPoints() -> [CLLocation] {
        
        return trackPointsArray.map {
            CLLocation(coordinate: CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude),
                       altitude: $0.altitude,
                       horizontalAccuracy: $0.horizontalAccuracy,
                       verticalAccuracy: $0.verticalAccuracy,
                       course: $0.course,
                       courseAccuracy: 0,
                       speed: $0.speed,
                       speedAccuracy: 0,
                       timestamp: $0.timestamp)
        }
        
    }

}
