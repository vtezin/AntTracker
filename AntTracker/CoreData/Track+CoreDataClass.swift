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
        
        if CurrentTrack.currentTrack.trackCoreData == track {
            CurrentTrack.currentTrack.reset()
        }
        
        track.deleteAllPoints(moc: moc)
        moc.delete(track)
        try? moc.save()
        
    }    
    
    func deleteAllPoints(moc: NSManagedObjectContext) {
        
        //let trackPointsArray = getTrackPointsAsArray()
        
        for point in trackPointsArray {
            moc.delete(point)
        }
        try? moc.save()
        
    }
    
    func fillByCurrentTrackData(moc: NSManagedObjectContext) {
        
        let currentTrack = CurrentTrack.currentTrack
        
        totalDistance = Int64(currentTrack.totalDistanceMeters)
        startDate = currentTrack.startDate
        finishDate = currentTrack.finishDate
        
        //saving points
        
        for index in 0..<currentTrack.points.count {
            
            let point = currentTrack.points[index]
            
            guard point.savedToDB == false else {continue}
            
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
               
            currentTrack.points[index].savedToDB = true
            
        }
        
    }
    
    func getStatistic(moc: NSManagedObjectContext) -> TrackStatistic {
        
        let pointsCD = getTrackPointsArrayFromCoreData(moc: moc)
        
        //FIXME: convert to geopoints need?
        let points: [CurrentTrack.TrackPoint] = pointsCD.map {
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
        
        averageSpeed = summSpeed / Double(points.count)
        
        let centerLatitude = minLatitude + (maxLatitude - minLatitude)/2
        let centerLongitude = minLongitude + (maxLongitude - minLongitude)/2
        
        let centerPoint = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
        
        let westPoint = CLLocation(latitude: minLatitude, longitude: minLongitude)
        let eastPoint = CLLocation(latitude: minLatitude, longitude: maxLongitude)
       
        let distFromWestToEast = westPoint.distance(from: eastPoint)
        
        let northPoint = CLLocation(latitude: maxLatitude, longitude: minLongitude)
        let southPoint = CLLocation(latitude: minLatitude, longitude: minLongitude)
       
        let distFromNorthToSouth = northPoint.distance(from: southPoint)
        
        return TrackStatistic(points: points,
                                  distFromWestToEast: distFromWestToEast,
                                  distFromNorthToSouth: distFromNorthToSouth,
                                  centerPoint: centerPoint,
                                  maxSpeed: maxSpeed,
                                  averageSpeed: averageSpeed,
                                  minAltitude: Int(minAltitude),
                                  maxAltitude: Int(maxAltitude))
        
        
    }
    
    
}

struct TrackStatistic {
    
    let points: [CurrentTrack.TrackPoint]
    
    let distFromWestToEast: CLLocationDistance
    let distFromNorthToSouth: CLLocationDistance
    let centerPoint: CLLocationCoordinate2D
    
    let maxSpeed: CLLocationSpeed
    let averageSpeed: CLLocationSpeed
    
    let minAltitude: Int
    let maxAltitude: Int
    
}

