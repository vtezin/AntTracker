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
    
    @Published var points: [GeoTrackPoint]
    @Published var title = ""
    
    var trackCoreData: Track?
    
    static let shared = GeoTrack()
    
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
        
        title = track.title
        
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
    
    func pushNewLocation(location: CLLocation) {
        if Int(location.horizontalAccuracy) <= 50 {
            points.append(GeoTrackPoint(location: location, type: ""))
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
        
        let points = accuracyPoints()
        
        for curPoint in points {
            
            if let _prevPoint = prevPoint {
                totalDistance += curPoint.location.distance(from: _prevPoint.location)
            }
            
            prevPoint = curPoint
        }
        
        return totalDistance
        
    }
    
    func totalDistanceString(maxAccuracy: Int) -> String {
        
        return localeDistanceString(distanceMeters: totalDistance(maxAccuracy: maxAccuracy))
        
    }
    
    func accuracyPoints() -> [GeoTrackPoint] {
        
        let maxAccuracy = 20
        
        return points.filter {
            Int($0.location.horizontalAccuracy) <= maxAccuracy
        }
        
    }
    
    var maxSpeed: CLLocationSpeed {
        
        if let maxSpeedPoint = accuracyPoints().max(by: { a, b in a.location.speed < b.location.speed}) {
            return maxSpeedPoint.location.speed
        }
        
        return 0
                
    }
    
    var averageSpeed: CLLocationSpeed {
        
        let pointsSpeedArray = accuracyPoints().map{Double($0.location.speed)}
        
        if pointsSpeedArray.count == 0 {
            return 0
        }
        
        return pointsSpeedArray.reduce(0, +) / Double(pointsSpeedArray.count)
        
    }
    
    var maxSpeedPoint: GeoTrackPoint? {
        
        if let maxSpeedPoint = accuracyPoints().max(by: { a, b in a.location.speed < b.location.speed}) {
            return maxSpeedPoint
        }
        
        return nil
        
    }
    
    var lastSpeed: CLLocationSpeed {
        
        let points = accuracyPoints()
        
        if points.count > 0 {
            return points.last!.location.speed
        }
        
        return 0
        
    }
    
    var maxAltitude: Int {
        
        if let maxAltPoint = accuracyPoints().max(by: { a, b in a.location.altitude < b.location.altitude}) {
            return Int(maxAltPoint.location.altitude)
        }
        
        return 0
                
    }
    
    var minAltitude: Int{
        
        if let maxAltPoint = accuracyPoints().min(by: { a, b in a.location.altitude < b.location.altitude}) {
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
    
    var durationSeconds: Int {
        
        if points.count == 0 {
            return 0
        } else {
            return Calendar.current.dateComponents([.second], from: startDate, to: finishDate).second ?? 0
        }
        
    }
    
    
    var northPoint: GeoTrackPoint? {
        
        if let foundedPoint = accuracyPoints().max(by: { a, b in a.location.latitudeDMS < b.location.latitudeDMS}) {
            return foundedPoint
        }
        
        return nil
        
    }
    
    
    var southPoint: GeoTrackPoint? {
        
        if let foundedPoint = accuracyPoints().min(by: { a, b in a.location.latitudeDMS < b.location.latitudeDMS}) {
            return foundedPoint
        }
        
        return nil
        
    }
    
    var westPoint: GeoTrackPoint? {
        
        if let foundedPoint = accuracyPoints().min(by: { a, b in a.location.longitudeDMS < b.location.longitudeDMS}) {
            return foundedPoint
        }
        
        return nil
        
    }
    
    var eastPoint: GeoTrackPoint? {
        
        if let foundedPoint = accuracyPoints().max(by: { a, b in a.location.longitudeDMS < b.location.longitudeDMS}) {
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
    
    func setTrackCoreDataProperties(trackCD: Track, moc: NSManagedObjectContext) {
        
        trackCD.totalDistance = Int64(totalDistance(maxAccuracy: 10))
        trackCD.startDate = startDate
        trackCD.finishDate = finishDate
        trackCD.showOnMap = true
        
        //saving points
        trackCD.deleteAllPoints(moc: moc)
        
        for point in points {
            let pointCoreData = TrackPoint(context: moc)
            
            pointCoreData.id = UUID()
            pointCoreData.track = trackCD
            
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
        
        trackCoreData = trackCD
        
    }
    
    func updateTrackInDB(moc: NSManagedObjectContext) {
        
        if let trckCD = trackCoreData {
            setTrackCoreDataProperties(trackCD: trckCD, moc: moc)
            try? moc.save()
        }
        
    }
        
}

struct PointOfTrack {
    
    let location: CLLocation
    let speed: CLLocationSpeed
    let distance: CLLocationDistance
    
}
