//
//  Track.swift
//  JustMap
//
//  Created by test on 09.03.2021.
//

import Foundation
import MapKit
import CoreData

class GeoTrack: ObservableObject {
    
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
    
    init(track: Track) {
        
        points = track.trackPointsArray.map {
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
    
    var maxSpeed: CLLocationSpeed {
        
        if let maxSpeedPoint = accuracyPoints(maxAccuracy: 10).max(by: { a, b in a.speed < b.speed}) {
            return maxSpeedPoint.speed
        }
        
        return 0
                
    }
    
    var lastSpeed: CLLocationSpeed {
        
        let points = accuracyPoints(maxAccuracy: 10)
        
        if points.count > 0 {
            return points.last!.speed
        }
        
        return 0
        
    }
    
    var maxAltitude: Int {
        
        if let maxAltPoint = accuracyPoints(maxAccuracy: 10).max(by: { a, b in a.altitude < b.altitude}) {
            return Int(maxAltPoint.altitude)
        }
        
        return 0
                
    }
    
    var minAltitude: Int {
        
        if let minAltPoint = accuracyPoints(maxAccuracy: 10).min(by: { a, b in a.altitude < b.altitude}) {
            return Int(minAltPoint.altitude)
        }
        
        return 0
                
    }
    
    var durationString: String {
        
        if points.count == 0 {
            return "-"
        }
        
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.allowedUnits = [.second, .minute, .hour, .day]
        dateComponentsFormatter.unitsStyle = .abbreviated
        return dateComponentsFormatter.string(from: startDate, to: finishDate) ?? "-"
        
    }
    
    var northPoint: CLLocation? {
        
        if let foundedPoint = accuracyPoints(maxAccuracy: 10).max(by: { a, b in a.latitude < b.latitude}) {
            return foundedPoint
        }
        
        return nil
        
    }
    
    
    var southPoint: CLLocation? {
        
        if let foundedPoint = accuracyPoints(maxAccuracy: 10).min(by: { a, b in a.latitude < b.latitude}) {
            return foundedPoint
        }
        
        return nil
        
    }
    
    var westPoint: CLLocation? {
        
        if let foundedPoint = accuracyPoints(maxAccuracy: 10).min(by: { a, b in a.longitude < b.longitude}) {
            return foundedPoint
        }
        
        return nil
        
    }
    
    var eastPoint: CLLocation? {
        
        if let foundedPoint = accuracyPoints(maxAccuracy: 10).max(by: { a, b in a.longitude < b.longitude}) {
            return foundedPoint
        }
        
        return nil
        
    }
    
    var centerPoint: CLLocationCoordinate2D? {
        
        guard let _northPoint = northPoint else { return nil }
        guard let _southPoint = southPoint else { return nil }
        guard let _westPoint = westPoint else { return nil }
        guard let _eastPoint = eastPoint else { return nil }
        
        let latitude = _southPoint.coordinate.latitude + (_northPoint.coordinate.latitude - _southPoint.coordinate.latitude)/2
        let longitude = _westPoint.coordinate.longitude + (_eastPoint.coordinate.longitude - _westPoint.coordinate.longitude)/2
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
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
