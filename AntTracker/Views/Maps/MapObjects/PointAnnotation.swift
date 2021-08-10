//
//  PointAnnotation.swift
//  AntTracker
//
//  Created by test on 19.05.2021.
//

import Foundation
import SwiftUI
import MapKit

class PointAnnotation: NSObject, MKAnnotation {
    
    let point: Point
    
    var coordinate = CLLocationCoordinate2D()
    var title: String? = ""
    var subtitle: String? = ""
    
    init(point: Point) {
        
        self.point = point
        self.coordinate = CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)
        
    }
    
    func setAnnotationView(on mapView: MKMapView) -> MKAnnotationView {
        
        //printTest("PointAnnotation" + #function)
        
        let identifier = "Point"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: self, reuseIdentifier: identifier)
            annotationView!.canShowCallout = false
        } else {
            annotationView!.annotation = self
        }
        
        let pointColor = UIColor(Color.getColorFromName(colorName: (point.color) )).withAlphaComponent(1)
        
        annotationView!.markerTintColor = pointColor
        annotationView!.glyphImage = UIImage(systemName: "star")
        
        // allow this to show pop up information
        annotationView?.canShowCallout = false

        annotationView!.displayPriority = .required
        annotationView!.titleVisibility = .adaptive
        
        // attach an information button to the view
        //annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        return annotationView!
        
    }
    
    
}


