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
        
        //print(#function)
        
        var geotrackToDraw: GeoTrack
        
        if let track = track {
            geotrackToDraw = track.convertToGeoTrack()
        } else {
            geotrackToDraw = geoTrack!
        }
        
        let drawingCurrentTrack = track == nil
        
        let trackPoints = geotrackToDraw.points
        
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
                if overlay.title == "current track" {
                    removeOverlays([overlay])
                }
            }
        }
        
        addOverlays([polyline])
        
        //ANNOTATIONS
        
        //start point
            
        let startPoint = trackPoints.first!
        
        let startPointAnnotation = TrackPointAnnotation(track: track, coordinate: startPoint.location.coordinate)
        startPointAnnotation.title = drawingCurrentTrack ? startPoint.location.timestamp.timeString() : startPoint.location.timestamp.dateString() + " ->"
        addTrackPointAnnotation(trackPointAnnotation: startPointAnnotation)
        
        //finish point
        
        if !drawingCurrentTrack {
            let finishPoint = trackPoints.last!
            let finishPointAnnotation = TrackPointAnnotation(track: track, coordinate: finishPoint.location.coordinate)
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

func setTrackOverlayRenderer(trackPolilyne: MKPolyline) -> MKOverlayRenderer {
    
    let pr = MKPolylineRenderer(overlay: trackPolilyne)
    
    let color = UIColor(Color.getColorFromName(colorName: (trackPolilyne.subtitle ?? "orange") )).withAlphaComponent(1)
    
    pr.lineWidth = 4
    
    pr.strokeColor = color
    
    return pr
    
}

class TrackPointAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    
    let track: Track?
    let colorName: String
    var title: String? = ""
    var subtitle: String? = ""
    
    init(track: Track?, coordinate: CLLocationCoordinate2D) {
        
        self.track = track
        
        var trackColor = ""
        
        if let track = track {
            trackColor = track.color
        } else {
            trackColor = currentTrackColorName()
        }
        
        self.colorName = trackColor
        self.coordinate = coordinate
        
    }
    
}

class TrackPolyline: MKPolyline {
    
    //TODO Make reusable polylines similar reusable trackpoints
    
    let track: Track?
    
    init(track: Track?) {
        self.track = track
    }
    
}

func setupTrackPointAnnotationView(for annotation: TrackPointAnnotation, on mapView: MKMapView) -> MKAnnotationView {
    
    //print(#function)
    
//    let reuseIdentifier = NSStringFromClass(TrackPointAnnotation.self)
//    let flagAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier, for: annotation)
    
//    flagAnnotationView.canShowCallout = true
//    
//    // Provide the annotation view's image.
//    let image = #imageLiteral(resourceName: "flag")
//    flagAnnotationView.image = image
//    
//    // Provide the left image icon for the annotation.
//    flagAnnotationView.leftCalloutAccessoryView = UIImageView(image: #imageLiteral(resourceName: "sf_icon"))
//    
//    // Offset the flag annotation so that the flag pole rests on the map coordinate.
//    let offset = CGPoint(x: image.size.width / 2, y: -(image.size.height / 2) )
//    flagAnnotationView.centerOffset = offset
    
//    let color = UIColor(Color.getColorFromName(colorName: (annotation.colorName) )).withAlphaComponent(1)
//    flagAnnotationView.backgroundColor = color
//
//    return flagAnnotationView
    
    let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "trackPoint")

    annotationView.markerTintColor = UIColor(Color.getColorFromName(colorName: (annotation.colorName) )).withAlphaComponent(1)
    
    return annotationView
    
}
