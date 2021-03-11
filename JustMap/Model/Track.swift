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
    
}
