//
//  Track.swift
//  JustMap
//
//  Created by test on 09.03.2021.
//

import Foundation
import MapKit

class CurrentTrack: ObservableObject {
    
    var points: [CLLocation]
    
    init() {
        points = [CLLocation]()
    }
    
    func reset() {
        self.points.removeAll()
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
        
}

struct PointOfTrack {
    
    let location: CLLocation
    let speed: CLLocationSpeed
    let distance: CLLocationDistance
    
}
