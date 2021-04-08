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
    
    var points: [GeoTrackPoint]
    var trackCoreData: Track?
    
    struct GeoTrackPoint {
        let location: CLLocation
        let type: String
    }
    
    var startDate: Date {
        if points.count == 0 {
            return Date()
        } else {
            return points[0].location.timestamp
        }
    }
    
    var finishDate: Date {
        if points.count == 0 {
            return Date()
        } else {
            return points.last!.location.timestamp
        }
    }
    
    init() {
        points = [GeoTrackPoint]()
    }
    
    init(track: Track) {
        
        points = track.trackPointsArray.map {
            
   
            let location =  CLLocation(coordinate: CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude),
                                                  altitude: $0.altitude,
                                                  horizontalAccuracy: $0.horizontalAccuracy,
                                                  verticalAccuracy: $0.verticalAccuracy,
                                                  course: $0.course,
                                                  courseAccuracy: 0,
                                                  speed: $0.speed,
                                                  speedAccuracy: 0,
                                                  timestamp: $0.timestamp)
            
            return GeoTrackPoint(location: location, type: "")
            

        }

        
    }
    
    func reset() {
        points.removeAll()
        trackCoreData = nil
    }
    
    func totalDistance(maxAccuracy: Int) -> CLLocationDistance {
        
        //TODO - add pauses respect
        
        var totalDistance: CLLocationDistance = 0
        var prevPoint: GeoTrackPoint? = nil
        
        let points = accuracyPoints(maxAccuracy: 10)
        
        for curPoint in points {
            
            if let _prevPoint = prevPoint {
                totalDistance += curPoint.location.distance(from: _prevPoint.location)
            }
            
            prevPoint = curPoint
        }
        
        return totalDistance
        
    }
    
    func totalDistanceString(maxAccuracy: Int) -> String {
        
        let formatter = MKDistanceFormatter()
        
        return formatter.string(fromDistance: totalDistance(maxAccuracy: maxAccuracy))
        
    }
    
    func accuracyPoints(maxAccuracy: Int) -> [GeoTrackPoint] {
        
        return points.filter {
            Int($0.location.horizontalAccuracy) <= maxAccuracy
        }
        
    }
    
    var maxSpeed: CLLocationSpeed {
        
        if let maxSpeedPoint = accuracyPoints(maxAccuracy: 10).max(by: { a, b in a.location.speed < b.location.speed}) {
            return maxSpeedPoint.location.speed
        }
        
        return 0
                
    }
    
    var lastSpeed: CLLocationSpeed {
        
        let points = accuracyPoints(maxAccuracy: 10)
        
        if points.count > 0 {
            return points.last!.location.speed
        }
        
        return 0
        
    }
    
    var maxAltitude: Int {
        
        if let maxAltPoint = accuracyPoints(maxAccuracy: 10).max(by: { a, b in a.location.altitude < b.location.altitude}) {
            return Int(maxAltPoint.location.altitude)
        }
        
        return 0
                
    }
    
    var minAltitude: Int {
        
        if let maxAltPoint = accuracyPoints(maxAccuracy: 10).min(by: { a, b in a.location.altitude < b.location.altitude}) {
            return Int(maxAltPoint.location.altitude)
        }
        
        return 0
                
    }
    
    var durationString: String {
        
        //TODO - add pauses respecting
        
        if points.count == 0 {
            return "-"
        }
        
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.allowedUnits = [.second, .minute, .hour, .day]
        dateComponentsFormatter.unitsStyle = .abbreviated
        return dateComponentsFormatter.string(from: startDate, to: finishDate) ?? "-"
        
    }
    
    var northPoint: GeoTrackPoint? {
        
        if let foundedPoint = accuracyPoints(maxAccuracy: 10).max(by: { a, b in a.location.latitude < b.location.latitude}) {
            return foundedPoint
        }
        
        return nil
        
    }
    
    
    var southPoint: GeoTrackPoint? {
        
        if let foundedPoint = accuracyPoints(maxAccuracy: 10).min(by: { a, b in a.location.latitude < b.location.latitude}) {
            return foundedPoint
        }
        
        return nil
        
    }
    
    var westPoint: GeoTrackPoint? {
        
        if let foundedPoint = accuracyPoints(maxAccuracy: 10).min(by: { a, b in a.location.longitude < b.location.longitude}) {
            return foundedPoint
        }
        
        return nil
        
    }
    
    var eastPoint: GeoTrackPoint? {
        
        if let foundedPoint = accuracyPoints(maxAccuracy: 10).max(by: { a, b in a.location.longitude < b.location.longitude}) {
            return foundedPoint
        }
        
        return nil
        
    }
    
    var centerPoint: CLLocationCoordinate2D? {
        
        guard let _northPoint = northPoint else { return nil }
        guard let _southPoint = southPoint else { return nil }
        guard let _westPoint = westPoint else { return nil }
        guard let _eastPoint = eastPoint else { return nil }
        
        let latitude = _southPoint.location.coordinate.latitude + (_northPoint.location.coordinate.latitude - _southPoint.location.coordinate.latitude)/2
        let longitude = _westPoint.location.coordinate.longitude + (_eastPoint.location.coordinate.longitude - _westPoint.location.coordinate.longitude)/2
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
    }
    
    
    func saveToDB(moc: NSManagedObjectContext, title: String) {
        
        var trackCoreDataForSave: Track
        
        if trackCoreData == nil {
            trackCoreDataForSave = Track(context: moc)
            trackCoreDataForSave.id = UUID()
            trackCoreDataForSave.title = title
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
            
            pointCoreData.latitude = Double(point.location.coordinate.latitude)
            pointCoreData.longitude = Double(point.location.coordinate.longitude)
            pointCoreData.altitude = Double(point.location.altitude)
            pointCoreData.verticalAccuracy = point.location.verticalAccuracy
            pointCoreData.horizontalAccuracy = point.location.horizontalAccuracy
            pointCoreData.timestamp = point.location.timestamp
            pointCoreData.speed = point.location.speed
            pointCoreData.course = Double(point.location.course)
            pointCoreData.type = point.type
            
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
