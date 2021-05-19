//
//  TrackPointAnnotation.swift
//  AntTracker
//
//  Created by test on 19.05.2021.
//

import Foundation
import SwiftUI
import MapKit

class TrackPointAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    
    let track: Track?
    let colorName: String
    let pointType: TrackPointType
    var title: String? = ""
    var subtitle: String? = ""
    
    init(track: Track?, coordinate: CLLocationCoordinate2D, pointType: TrackPointType) {
        
        self.track = track
        
        var trackColor = ""
        
        if let track = track {
            trackColor = track.color
        } else {
            trackColor = currentTrackColorName()
        }
        
        self.colorName = trackColor
        self.coordinate = coordinate
        self.pointType = pointType
        
    }
    
    enum TrackPointType {
        case start
        case finish
    }
    
    func setAnnotationView(on mapView: MKMapView) -> MKAnnotationView {
        
        printTest(#function)
        
        let identifier = "trackPoint"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: self, reuseIdentifier: identifier)
            annotationView!.canShowCallout = false
        } else {
            annotationView!.annotation = self
            printTest("reuse annotation")
        }
        
        let pointColor = UIColor(Color.getColorFromName(colorName: (colorName) )).withAlphaComponent(1)
        
        annotationView!.markerTintColor = pointColor
        
        if pointType == .start {
            annotationView!.glyphImage = UIImage(systemName: "ant")
        } else {
            annotationView!.glyphImage = UIImage(systemName: "checkmark.circle")
        }
        
        return annotationView!
        
    }
    
}

