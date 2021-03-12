//
//  Track.swift
//  JustMap
//
//  Created by test on 09.03.2021.
//

import Foundation
import MapKit

class Track: ObservableObject {
    
    var points: [CLLocation]
    
    init() {
        points = [CLLocation]()
    }
    
    func reset() {
        self.points.removeAll()
    }
    
    func totalDistance() -> Int {
        
        var totalDistance = 0
        
        var prevPoint: CLLocation? = nil
        
        for curPoint in points {
            
            if let _prevPoint = prevPoint {
                totalDistance += Int(curPoint.distance(from: _prevPoint))
            }
            
            prevPoint = curPoint
        }
        
        return totalDistance
        
    }
    
}
