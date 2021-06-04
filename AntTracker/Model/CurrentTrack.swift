//
//  CurrentTrack.swift
//  AntTracker
//
//  Created by test on 03.06.2021.
//

import Foundation
import MapKit

//TODO may be delete protocol
protocol TrackWhithInfo: ObservableObject {
    
    var startDate: Date { get }
    var finishDate: Date { get }
    var durationString: String { get }
    var maxSpeed: CLLocationSpeed { get }
    var averageSpeed: CLLocationSpeed { get }
    var maxAltitude: Int { get }
    var minAltitude: Int { get }
    var totalDistanceMeters: CLLocationDistance { get }
    
}

class CurrentTrack: ObservableObject, TrackWhithInfo {
    
    @Published var startDate = Date()
    @Published var finishDate = Date()
    
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
    
    @Published var lastSpeed: CLLocationSpeed = 0
    @Published var maxSpeed: CLLocationSpeed = 0
    var summSpeed: CLLocationSpeed = 0
    
    var averageSpeed: CLLocationSpeed {
        return summSpeed / Double(points.count)
    }
    
    @Published var lastAltitude: Int = 0
    @Published var maxAltitude: Int = 0
    @Published var minAltitude: Int = 0
    
    @Published var totalDistanceMeters: CLLocationDistance = 0
    
    var points = [TrackPoint]()
    var trackCoreData: Track? = nil
    
    static let currentTrack = CurrentTrack()
    
    init() {
        
    }
    
    //init from CoreData track
    //will use in future for restore from saved track
    init(trackCD: Track) {
        
        points = trackCD.trackPointsArray.map {
            
   
            let location =  CLLocation(coordinate: CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude),
                                                  altitude: $0.altitude,
                                                  horizontalAccuracy: $0.horizontalAccuracy,
                                                  verticalAccuracy: $0.verticalAccuracy,
                                                  course: $0.course,
                                                  courseAccuracy: 0,
                                                  speed: $0.speed,
                                                  speedAccuracy: 0,
                                                  timestamp: $0.timestamp)
            
            return TrackPoint(location: location, type: "")
            
        }
        
        trackCoreData = trackCD
        //TODO update statistics here
        
    }
    
    struct TrackPoint {
        let location: CLLocation
        let type: String
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
        
    }
    
    func addNewPointFromLocation(location: CLLocation) {
        
        guard Int(location.horizontalAccuracy) <= 20 else {return}
        
        if points.count == 0 {
            //init by first point
            startDate = location.timestamp
            finishDate = location.timestamp
            minAltitude = Int(location.altitude)
            maxAltitude = Int(location.altitude)
            maxSpeed = location.speed
            summSpeed = location.speed
            totalDistanceMeters = 0
        } else {
            totalDistanceMeters += location.distance(from: points.last!.location)
            summSpeed += location.speed
            
            finishDate = location.timestamp
            lastSpeed = location.speed
            maxSpeed = max(location.speed, maxSpeed)
            lastAltitude = Int(location.altitude)
            maxAltitude = max(lastAltitude, maxAltitude)
            
        }
        
        points.append(TrackPoint(location: location, type: ""))
        
    }
    
}
    
