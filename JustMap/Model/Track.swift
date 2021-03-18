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
    
    func totalDistance() -> CLLocationDistance {
        
        var totalDistance: CLLocationDistance = 0
        
        var prevPoint: CLLocation? = nil
        
        for curPoint in points {
            
            if let _prevPoint = prevPoint {
                totalDistance += curPoint.distance(from: _prevPoint)
            }
            
            prevPoint = curPoint
        }
        
        return totalDistance
        
    }
    
    func totalDistanceString() -> String {
        
        let formatter = MKDistanceFormatter()
        
        return formatter.string(fromDistance: totalDistance())        
        
    }
    
    
    
}
