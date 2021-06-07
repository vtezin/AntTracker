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
    
    func geoPoints() -> [CurrentTrack.TrackPoint] {
        
        return trackPointsArray.map {
            let location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: $0.latitude,
                                                                         longitude: $0.longitude),
                                      altitude: $0.altitude,
                                      horizontalAccuracy: $0.horizontalAccuracy,
                                      verticalAccuracy: $0.verticalAccuracy,
                                      course: $0.course,
                                      courseAccuracy: 0,
                                      speed: $0.speed,
                                      speedAccuracy: 0,
                                      timestamp: $0.timestamp)
            return CurrentTrack.TrackPoint(location: location, type: "")
            
        }
        
    }
    
    func fillByCurrentTrackData(moc: NSManagedObjectContext) {
        
        let currentTrack = CurrentTrack.currentTrack
        
        totalDistance = Int64(currentTrack.totalDistanceMeters)
        startDate = currentTrack.startDate
        finishDate = currentTrack.finishDate
        
        //saving points
        deleteAllPoints(moc: moc)
        
        for point in currentTrack.points {
            
            let pointCoreData = TrackPoint(context: moc)
            
            pointCoreData.id = UUID()
            pointCoreData.track = self
            
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
        
    }
    
    func getStatictic() -> trackStatistics {
        
        print(Date())
        let points = geoPoints()
        print(Date(), "points getted")
        
        var northestPoint: CLLocation?
        var southestPoint: CLLocation?
        var westestPoint: CLLocation?
        var eastestPoint: CLLocation?
        var centerPoint: CLLocationCoordinate2D?
        
        if let foundedPoint = points.max(by: { a, b in a.location.latitudeDMS < b.location.latitudeDMS}) {
            northestPoint = foundedPoint.location
        }
        
        if let foundedPoint = points.min(by: { a, b in a.location.latitudeDMS < b.location.latitudeDMS}) {
            southestPoint = foundedPoint.location
        }
        
        if let foundedPoint = points.max(by: { a, b in a.location.longitudeDMS < b.location.longitudeDMS}) {
            eastestPoint = foundedPoint.location
        }
        
        if let foundedPoint = points.min(by: { a, b in a.location.longitudeDMS < b.location.longitudeDMS}) {
            westestPoint = foundedPoint.location
        }
        
        if let _northPoint = northestPoint,
           let _southPoint = southestPoint,
           let _eastPoint = eastestPoint,
           let _westPoint = westestPoint
        
        {
            let latitude = _southPoint.coordinate.latitude + (_northPoint.coordinate.latitude - _southPoint.coordinate.latitude)/2
            let longitude = _westPoint.coordinate.longitude + (_eastPoint.coordinate.longitude - _westPoint.coordinate.longitude)/2
            
            centerPoint = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        
        print(Date(), "control points founded")
        
        var minAltitude: Int = 0
        var maxAltitude: Int = 0
        
        if let altPoint = points.max(by: { a, b in a.location.altitude < b.location.altitude}) {
            maxAltitude = Int(altPoint.location.altitude)
        }
        
        if let altPoint = points.min(by: { a, b in a.location.altitude < b.location.altitude}) {
            minAltitude = Int(altPoint.location.altitude)
        }
        
        var maxSpeed: CLLocationSpeed = 0
        
        if let maxSpeedPoint = points.max(by: { a, b in a.location.speed < b.location.speed}) {
            maxSpeed = maxSpeedPoint.location.speed
        }
        
        var averageSpeed: CLLocationSpeed = 0
        
        if points.count > 0 {
            
            var speedSumm: Double = 0
            for point in points {
                speedSumm += point.location.speed
            }
            
            averageSpeed = speedSumm / Double(points.count)
            
        }
        
        print(Date())
        print("get statistic points: \(points.count)")
        
        return trackStatistics(points: points,
                               northestPoint: northestPoint,
                               southestPoint: southestPoint,
                               westestPoint: westestPoint,
                               eastestPoint: eastestPoint,
                               centerPoint: centerPoint,
                               maxSpeed: maxSpeed,
                               averageSpeed: averageSpeed,
                               minAltitude: minAltitude,
                               maxAltitude: maxAltitude)
        
    }
    
    func newGetStatictic() -> newTrackStatistics {
        
        print(Date())
        let points = geoPoints()
        print(Date(), "points getted")
        
        var maxLatitude: Double = 0
        var minLatitude: Double = 0
        var maxLongitude: Double = 0
        var minLongitude: Double = 0
        
        var maxSpeed: CLLocationSpeed = 0
        var summSpeed: CLLocationSpeed = 0
        var averageSpeed: CLLocationSpeed = 0
        
        var minAltitude: Double = 0
        var maxAltitude: Double = 0
        
        var isFirstPoint = true
        
        for point in points {
            
            if isFirstPoint {
                
                minLatitude = point.location.coordinate.latitude
                minLongitude = point.location.coordinate.longitude
                maxLatitude = point.location.coordinate.latitude
                maxLongitude = point.location.coordinate.longitude
                
                minAltitude = point.location.altitude
                
                isFirstPoint = false
                
            } else {
                
                maxLatitude = max(maxLatitude, point.location.coordinate.latitude)
                minLatitude = min(minLatitude, point.location.coordinate.latitude)
                
                maxLongitude = max(maxLongitude, point.location.coordinate.longitude)
                minLongitude = min(minLongitude, point.location.coordinate.longitude)
                
                maxSpeed = max(maxSpeed, point.location.speed)
                summSpeed += point.location.speed
                
                maxAltitude = max(maxAltitude, point.location.altitude)
                minAltitude = min(minAltitude, point.location.altitude)
                
            }
            
        }
        
        averageSpeed = summSpeed / Double(geoPoints().count)
        
        let centerLatitude = minLatitude + (maxLatitude - minLatitude)/2
        let centerLongitude = minLongitude + (maxLongitude - minLongitude)/2
        
        let centerPoint = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
        
        let westPoint = CLLocation(latitude: minLatitude, longitude: minLongitude)
        let eastPoint = CLLocation(latitude: minLatitude, longitude: maxLongitude)
       
        let distFromWestToEast = westPoint.distance(from: eastPoint)
        
        let northPoint = CLLocation(latitude: maxLatitude, longitude: minLongitude)
        let southPoint = CLLocation(latitude: minLatitude, longitude: minLongitude)
       
        let distFromNorthToSouth = northPoint.distance(from: southPoint)
            
        print(Date())
        print("get statistic points: \(points.count)")
        
        
        return newTrackStatistics(points: points,
                                  distFromWestToEast: distFromWestToEast,
                                  distFromNorthToSouth: distFromNorthToSouth,
                                  centerPoint: centerPoint,
                                  maxSpeed: maxSpeed,
                                  averageSpeed: averageSpeed,
                                  minAltitude: Int(minAltitude),
                                  maxAltitude: Int(maxAltitude))
        
        
    }
    
    
}

struct newTrackStatistics {
    
    let points: [CurrentTrack.TrackPoint]
    
    let distFromWestToEast: CLLocationDistance
    let distFromNorthToSouth: CLLocationDistance
    let centerPoint: CLLocationCoordinate2D
    
    let maxSpeed: CLLocationSpeed
    let averageSpeed: CLLocationSpeed
    
    let minAltitude: Int
    let maxAltitude: Int
    
}

struct trackStatistics {
    
    var points = [CurrentTrack.TrackPoint]()
    
    var northestPoint: CLLocation?
    var southestPoint: CLLocation?
    var westestPoint: CLLocation?
    var eastestPoint: CLLocation?
    var centerPoint: CLLocationCoordinate2D?
    
    var maxSpeed: CLLocationSpeed
    var averageSpeed: CLLocationSpeed
    
    var minAltitude: Int
    var maxAltitude: Int
    
}
