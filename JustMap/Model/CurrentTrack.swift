//
//  Track.swift
//  JustMap
//
//  Created by test on 09.03.2021.
//

import Foundation
import MapKit
import CoreData

class CurrentTrack: ObservableObject {
    
    var points: [CLLocation]
    var trackCoreData: Track?
    
    var startDate: Date {
        if points.count == 0 {
            return Date()
        } else {
            return points[0].timestamp
        }
    }
    
    var finishDate: Date {
        if points.count == 0 {
            return Date()
        } else {
            return points.last!.timestamp
        }
    }
    
    init() {
        points = [CLLocation]()
    }
    
    func reset() {
        points.removeAll()
        trackCoreData = nil
    }
    
    func totalDistance(maxAccuracy: Int) -> CLLocationDistance {
        
        var totalDistance: CLLocationDistance = 0
        var prevPoint: CLLocation? = nil
        
        let points = accuracyPoints(maxAccuracy: 10)
        
        for curPoint in points {
            
            if let _prevPoint = prevPoint {
                totalDistance += curPoint.distance(from: _prevPoint)
            }
            
            prevPoint = curPoint
        }
        
        return totalDistance
        
    }
    
    func totalDistanceString(maxAccuracy: Int) -> String {
        
        let formatter = MKDistanceFormatter()
        
        return formatter.string(fromDistance: totalDistance(maxAccuracy: maxAccuracy))
        
    }
    
    func accuracyPoints(maxAccuracy: Int) -> [CLLocation] {
        
        return points.filter {
            Int($0.horizontalAccuracy) <= maxAccuracy
        }
        
    }
    
    func maxSpeed() -> CLLocationSpeed {
        
        if let maxSpeedPoint = accuracyPoints(maxAccuracy: 10).max(by: { a, b in a.speed < b.speed}) {
            return maxSpeedPoint.speed
        }
        
        return 0
                
    }
    
    func lastSpeed() -> CLLocationSpeed {
        
        let points = accuracyPoints(maxAccuracy: 10)
        
        if points.count > 0 {
            return points.last!.speed
        }
        
        return 0
        
    }
    
    func saveToDB(moc: NSManagedObjectContext) {
        
        var trackCoreDataForSave: Track
        
        if trackCoreData == nil {
            trackCoreDataForSave = Track(context: moc)
            trackCoreDataForSave.id = UUID()
            trackCoreDataForSave.title = Date().dateString()
            trackCoreDataForSave.info = ""
            trackCoreDataForSave.region = ""
            trackCoreDataForSave.color = "blue"
        } else {
            trackCoreDataForSave = trackCoreData!
            trackCoreDataForSave.deleteAllPoints(moc: moc)
        }
        
        trackCoreDataForSave.totalDistance = Int64(totalDistance(maxAccuracy: 10))
        trackCoreDataForSave.startDate = startDate
        trackCoreDataForSave.finishDate = finishDate
        trackCoreDataForSave.showOnMap = true
        
        //saving points
        for point in points {
            let pointCoreData = TrackPoint(context: moc)
            
            pointCoreData.id = UUID()
            pointCoreData.track = trackCoreDataForSave
            
            pointCoreData.latitude = Double(point.coordinate.latitude)
            pointCoreData.longitude = Double(point.coordinate.longitude)
            pointCoreData.altitude = Double(point.altitude)
            pointCoreData.verticalAccuracy = point.verticalAccuracy
            pointCoreData.horizontalAccuracy = point.horizontalAccuracy
            pointCoreData.timestamp = point.timestamp
            
        }
        
        try? moc.save()
        
        trackCoreData = trackCoreDataForSave
        
    }
    
        
}

struct PointOfTrack {
    
    let location: CLLocation
    let speed: CLLocationSpeed
    let distance: CLLocationDistance
    
}
