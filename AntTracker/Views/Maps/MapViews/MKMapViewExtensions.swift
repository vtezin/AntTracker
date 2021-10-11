//
//  MKMapViewExtensions.swift
//  AntTracker
//
//  Created by test on 11.10.2021.
//

import Foundation
import MapKit

extension MKMapView {
    
    func locationIsOnVisibleArea(coordinate: CLLocationCoordinate2D) -> Bool {
        return visibleMapRect.contains(MKMapPoint(coordinate))
    }
    
}
