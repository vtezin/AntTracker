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
public class Track: NSManagedObject, TrackWhithInfo {
    
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
    
    
    func northestPoint() -> CLLocation? {
        if let foundedPoint = geoPoints().max(by: { a, b in a.location.latitudeDMS < b.location.latitudeDMS}) {
            return foundedPoint.location
        }
        return nil
    }
   
    func southestPoint() -> CLLocation? {
        if let foundedPoint = geoPoints().min(by: { a, b in a.location.latitudeDMS < b.location.latitudeDMS}) {
            return foundedPoint.location
        }
        return nil
    }
    
    func westestPoint() -> CLLocation? {
        if let foundedPoint = geoPoints().min(by: { a, b in a.location.longitudeDMS < b.location.longitudeDMS}) {
            return foundedPoint.location
        }
        return nil
    }
    
    func eastestPoint() -> CLLocation? {
        if let foundedPoint = geoPoints().max(by: { a, b in a.location.longitudeDMS < b.location.longitudeDMS}) {
            return foundedPoint.location
        }
        return nil
    }

    
    func centerPoint() -> CLLocationCoordinate2D? {
        
        guard let _northPoint = northestPoint() else { return nil }
        guard let _southPoint = southestPoint() else { return nil }
        guard let _westPoint = westestPoint() else { return nil }
        guard let _eastPoint = eastestPoint() else { return nil }
        
        let latitude = _southPoint.coordinate.latitude + (_northPoint.coordinate.latitude - _southPoint.coordinate.latitude)/2
        let longitude = _westPoint.coordinate.longitude + (_eastPoint.coordinate.longitude - _westPoint.coordinate.longitude)/2
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
    }
    

}
