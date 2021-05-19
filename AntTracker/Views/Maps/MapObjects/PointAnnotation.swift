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
        
        printTest(#function)
        
        let identifier = "Point"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: self, reuseIdentifier: identifier)
            annotationView!.canShowCallout = false
        } else {
            annotationView!.annotation = self
            printTest("reuse annotation")
        }
        
        let pointColor = UIColor(Color.getColorFromName(colorName: (point.color) )).withAlphaComponent(1)
        
        annotationView!.markerTintColor = pointColor
        
        // allow this to show pop up information
        annotationView?.canShowCallout = true

        // attach an information button to the view
        annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        return annotationView!
        
    }
    
    
}


