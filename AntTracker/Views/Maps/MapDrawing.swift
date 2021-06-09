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
    
    func addTrackLine(trackPoints: [CurrentTrack.TrackPoint], trackTitle: String, trackColor: String) {
        
        printTest(#function)
        
        guard !trackPoints.isEmpty else {
            return
        }
        
        // FIXME: more smart detecting
        
        let drawingCurrentTrack = trackTitle == "current track"
        
        var coordinates = [CLLocationCoordinate2D]()
        for point in trackPoints {
            coordinates.append(point.location.coordinate)
        }
        
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        

        polyline.title = trackTitle
        polyline.subtitle = trackColor

        
        //drawing track line
        if drawingCurrentTrack {
            //redrawing
            for overlay in overlays {
                
                if let trackPolyline = overlay as? MKPolyline {
                    
                    if trackPolyline.title == "current track" {
                        removeOverlays([trackPolyline])
                    }
                    
                }
                
            }
            addOverlays([polyline])
            
        } else {
         //just drawing
            addOverlays([polyline])
        }
        
        //ANNOTATIONS
        
        //start point
            
        let startPoint = trackPoints.first!
        
        let startPointAnnotation = TrackPointAnnotation(trackColor: trackColor, coordinate: startPoint.location.coordinate, pointType: .start)
        startPointAnnotation.title = drawingCurrentTrack ? startPoint.location.timestamp.timeString() : startPoint.location.timestamp.dateString()
        addTrackPointAnnotation(trackPointAnnotation: startPointAnnotation)
        
        //finish point
        
        if !drawingCurrentTrack {
            let finishPoint = trackPoints.last!
            let finishPointAnnotation = TrackPointAnnotation(trackColor: trackColor, coordinate: finishPoint.location.coordinate, pointType: .finish)
            finishPointAnnotation.title = finishPoint.location.timestamp.timeString()
            addTrackPointAnnotation(trackPointAnnotation: finishPointAnnotation)
        }
    
    }
    
    func addTrackPointAnnotation(trackPointAnnotation: TrackPointAnnotation) {
        
        for annotation in annotations {
            if let annotation = annotation as? TrackPointAnnotation{
                if annotation.title == trackPointAnnotation.title {
                    //trackPointAnnotation alredy exist
                    return
                }
            }
        }
        
        addAnnotation(trackPointAnnotation)
        
    }

}

func setAnnotationView(annotation:MKAnnotation) -> MKAnnotationView? {
    
    let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")

    annotationView.markerTintColor = UIColor(red: (69.0/255), green: (95.0/255), blue: (170.0/255), alpha: 1.0)
    
    return annotationView
    
}

func removeCurrentTrackFromMapView(mapView: MKMapView) {
    //removing current track overlay
    
    printTest(#function)
    
    let currentTracks = mapView.overlays.filter { $0.title == "current track" }
    
    if currentTracks.count == 0 {
        //nothing to remove
        return
    }
    
    mapView.removeOverlays([currentTracks[0]])
    
    //removing current track annotations
    
    let annotationsCurrentTrack = mapView.annotations.filter {
        
        if $0 is TrackPointAnnotation{
                return true
        }
        return false
    }
    
    mapView.removeAnnotations(annotationsCurrentTrack)
    
}
