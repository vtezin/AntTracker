//
//  MapDrawing.swift
//  AntTracker
//
//  Created by test on 12.04.2021.
//

import MapKit
import Foundation
import SwiftUI

extension MKMapView {
    
    func addTrackLine(geoTrack: GeoTrack, title: String, subtitle: String, currentTrackDrawing: Bool) {
        
        let trackPoints = geoTrack.points
        
        if trackPoints.isEmpty {
            return
        }
        
        var coordinates = [CLLocationCoordinate2D]()
        for point in trackPoints {
            coordinates.append(point.location.coordinate)
        }
        
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        polyline.title = title
        polyline.subtitle = subtitle
        
        //removing old track overlay
        
        for overlay in overlays {
            if overlay.title == title {
                removeOverlays([overlay])
            }
        }
        
        addOverlays([polyline])
                
        //start point
            
        var annotations = [MKPointAnnotation]()
        
        let startPoint = trackPoints.first!
        
        let startAnnotation = MKPointAnnotation()
        
        startAnnotation.title = currentTrackDrawing ? startPoint.location.timestamp.timeString() : startPoint.location.timestamp.dateString() + " ->"
        startAnnotation.subtitle = currentTrackDrawing ? "currentTrackStart" : "trackStart"
        startAnnotation.coordinate = startPoint.location.coordinate
        
        annotations.append(startAnnotation)
        
        //finish point
        
        if !currentTrackDrawing {
            
            let finishPoint = trackPoints.last!
            
            let finishAnnotation = MKPointAnnotation()
            
            finishAnnotation.title = finishPoint.location.timestamp.timeString()
            finishAnnotation.subtitle = currentTrackDrawing ? "currentTrackFinish" : "trackFinish"
            finishAnnotation.coordinate = finishPoint.location.coordinate
            
            annotations.append(finishAnnotation)
            
        }
        
        //removeAnnotations(annotations)
        addAnnotations(annotations)
    
    }
    
}

func setAnnotationView(annotation:MKAnnotation, showFinish: Bool) -> MKAnnotationView? {
    
    if annotation.subtitle == "currentTrackStart" || annotation.subtitle == "trackStart" {
        
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")

        annotationView.markerTintColor = UIColor(red: (69.0/255), green: (95.0/255), blue: (170.0/255), alpha: 1.0)
        
        return annotationView
        
    } else if showFinish && (annotation.subtitle == "currentTrackFinish" || annotation.subtitle == "trackFinish") {
      
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
        annotationView.markerTintColor = UIColor(red: (146.0/255), green: (187.0/255), blue: (217.0/255), alpha: 1.0)
        return annotationView
        
    }
    
    return nil
}

func setTrackOverlayRenderer(trackPolilyne: MKPolyline) -> MKOverlayRenderer {
    
    let pr = MKPolylineRenderer(overlay: trackPolilyne)
    
    let color = UIColor(Color.getColorFromName(colorName: (trackPolilyne.subtitle ?? "orange") )).withAlphaComponent(1)
    
    pr.lineWidth = 4
    
    pr.strokeColor = color
    
    return pr
    
}
