//
//  CurrentTrack.swift
//  AntTracker
//
//  Created by test on 03.06.2021.
//

import Foundation
import MapKit
import CoreData
import SwiftUI

class CurrentTrack: ObservableObject {
    
    var startDate = Date()
    @Published var lastSaveDate = Date()
    @Published var finishDate = Date()
    
    var durationString: String {
        
        //TODO: - add pauses respecting
        
        if points.count == 0 {
            return "-"
        }
        
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.allowedUnits = [.second, .minute, .hour, .day]
        dateComponentsFormatter.unitsStyle = .abbreviated
        return dateComponentsFormatter.string(from: startDate, to: finishDate) ?? "-"
        
    }
    
    var lastSpeed: CLLocationSpeed = 0
    
    //statistic
    var maxSpeed: CLLocationSpeed = 0
    var summSpeed: CLLocationSpeed = 0
    
    var averageSpeed: CLLocationSpeed {
        return summSpeed / Double(points.count)
    }
    
    var maxLatitude: Double = 0
    var minLatitude: Double = 0
    var maxLongitude: Double = 0
    var minLongitude: Double = 0
    
    var lastAltitude: Int = 0
    var maxAltitude: Int = 0
    var minAltitude: Int = 0
    
    var totalDistanceMeters: CLLocationDistance = 0
    
    var points = [TrackPoint]()
    var trackCoreData: Track? = nil
    var trackCoreDataRestoredForResume = false
    
    var lastSavedLocation = CLLocation()
    
    static let currentTrack = CurrentTrack()    
    
    init() {
    }
    
    //init from CoreData track
    //will use in future for restore from saved track
    func fillByTrackCoreData(trackCD: Track) {
        
        points.removeAll()
        
        for trackCoreDataPoint in trackCD.trackPointsArray {
            let location =  CLLocation(coordinate: CLLocationCoordinate2D(latitude: trackCoreDataPoint.latitude,
                                                                          longitude: trackCoreDataPoint.longitude),
                                       altitude: trackCoreDataPoint.altitude,
                                       horizontalAccuracy: trackCoreDataPoint.horizontalAccuracy,
                                       verticalAccuracy: trackCoreDataPoint.verticalAccuracy,
                                       course: trackCoreDataPoint.course,
                                       courseAccuracy: 0,
                                       speed: trackCoreDataPoint.speed,
                                       speedAccuracy: 0,
                                       timestamp: trackCoreDataPoint.timestamp)
            addNewPointFromLocation(location: location)
        }
        
        trackCoreData = trackCD
        trackCoreDataRestoredForResume = true
        //TODO: update statistics here
        
    }
    
    struct TrackPoint {
        let location: CLLocation
        let type: String
        var savedToDB = false
    }
    
    func reset() {
        points.removeAll()
        trackCoreData = nil
        
        //clear statistic
        minAltitude = 0
        maxAltitude = 0
        maxSpeed = 0
        summSpeed = 0
        totalDistanceMeters = 0
        
        maxLatitude = 0
        minLatitude = 0
        maxLongitude = 0
        minLongitude = 0
        
        lastSavedLocation = CLLocation()
        
    }
    
    func addNewPointFromLocation(location: CLLocation) {
        
        guard Int(location.horizontalAccuracy) <= 20 else {return}
        
        if points.count == 0 {
            //init by first point
            startDate = location.timestamp
            finishDate = location.timestamp
            
            minLatitude = location.coordinate.latitude
            minLongitude = location.coordinate.longitude
            maxLatitude = location.coordinate.latitude
            maxLongitude = location.coordinate.longitude
            
            minAltitude = Int(location.altitude)
            maxAltitude = Int(location.altitude)
            maxSpeed = location.speed
            summSpeed = location.speed
            totalDistanceMeters = 0
        } else {
            
            let distanceFromLastLocation = location.distance(from: lastSavedLocation)
            
            guard distanceFromLastLocation > 5 else {return}
            guard distanceFromLastLocation > location.speed.roundedForKmH() else {return}
            
            totalDistanceMeters += location.distance(from: points.last!.location)
            summSpeed += location.speed
            
            finishDate = location.timestamp
            lastSpeed = location.speed
            maxSpeed = max(location.speed, maxSpeed)
            lastAltitude = Int(location.altitude)
            maxAltitude = max(lastAltitude, maxAltitude)
            
            maxLatitude = max(maxLatitude, location.coordinate.latitude)
            minLatitude = min(minLatitude, location.coordinate.latitude)
            
            maxLongitude = max(maxLongitude, location.coordinate.longitude)
            minLongitude = min(minLongitude, location.coordinate.longitude)
            
        }
        
        points.append(TrackPoint(location: location, type: ""))
        
        lastSavedLocation = location
        
        //saving to core data
        if location.timestamp.seconds(from: lastSaveDate) > 5 {
            
            if let trackCD = CurrentTrack.currentTrack.trackCoreData {
                let moc = PersistenceController.shared.container.viewContext
                trackCD.fillByCurrentTrackData(moc: moc)
                try? moc.save()
            }
            
            lastSaveDate = location.timestamp
            
        }
        
    }
    
    func prepareForStartRecording(moc: NSManagedObjectContext) {
        
        guard trackCoreData == nil else { return }
        
        let trackCD = Track(context: moc)
        trackCD.title = Date().dateString()
        trackCD.id = UUID()
        trackCD.startDate = Date()
        trackCD.finishDate = Date()
        
        try? moc.save()
        
        trackCoreData = trackCD
        
    }
    
}
    
