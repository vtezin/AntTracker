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
    
    func addTrackLine(track: Track?, geoTrack: GeoTrack?) {
        
        var geotrackToDraw: GeoTrack
        
        if let track = track {
            geotrackToDraw = track.convertToGeoTrack()
        } else {
            geotrackToDraw = geoTrack!
        }
        
        printTest(#function)
        
        let drawingCurrentTrack = track == nil
        
        let trackPoints = geotrackToDraw.accuracyPoints()
        
        if trackPoints.isEmpty {
            return
        }
        
        var coordinates = [CLLocationCoordinate2D]()
        for point in trackPoints {
            coordinates.append(point.location.coordinate)
        }
        
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        
        if drawingCurrentTrack {
            polyline.title = "current track"
            polyline.subtitle = currentTrackColorName()
        } else {
            polyline.title = track!.title
            polyline.subtitle = track!.color
        }
        
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
        
        let startPointAnnotation = TrackPointAnnotation(track: track, coordinate: startPoint.location.coordinate, pointType: .start)
        startPointAnnotation.title = drawingCurrentTrack ? startPoint.location.timestamp.timeString() : startPoint.location.timestamp.dateString()
        addTrackPointAnnotation(trackPointAnnotation: startPointAnnotation)
        
        //finish point
        
        if !drawingCurrentTrack {
            let finishPoint = trackPoints.last!
            let finishPointAnnotation = TrackPointAnnotation(track: track, coordinate: finishPoint.location.coordinate, pointType: .finish)
            finishPointAnnotation.title = finishPoint.location.timestamp.timeString()
            addTrackPointAnnotation(trackPointAnnotation: finishPointAnnotation)
        }
    
    }
    
    func addTrackPointAnnotation(trackPointAnnotation: TrackPointAnnotation) {
        
        for annotation in annotations {
            if let annotation = annotation as? TrackPointAnnotation{
                if annotation.track == trackPointAnnotation.track && annotation.title == trackPointAnnotation.title {
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
        
        if let annotation = $0 as? TrackPointAnnotation{
            if annotation.track == nil {
                return true
            }
        }
        return false
    }
    
    mapView.removeAnnotations(annotationsCurrentTrack)
    
}
