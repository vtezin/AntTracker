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

func setTrackOverlayRenderer(trackPolilyne: MKPolyline) -> MKOverlayRenderer {
    
    let pr = MKPolylineRenderer(overlay: trackPolilyne)
    
    let color = UIColor(Color.getColorFromName(colorName: (trackPolilyne.subtitle ?? "orange") )).withAlphaComponent(1)
    
    pr.lineWidth = 4
    
    pr.strokeColor = color
    
    return pr
    
}

class TrackPolyline: MKPolyline {
    
    //TODO Make reusable polylines similar reusable trackpoints
    
    let track: Track?
    
    init(track: Track?) {
        self.track = track
    }
    
}

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
    
}

func setupTrackPointAnnotationView(for annotation: TrackPointAnnotation, on mapView: MKMapView) -> MKAnnotationView {

    printTest(#function)
    
    let identifier = "trackPoint"
    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

    if annotationView == nil {
        annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        annotationView!.canShowCallout = false
    } else {
        annotationView!.annotation = annotation
        printTest("reuse annotation")
    }
    
    let pointColor = UIColor(Color.getColorFromName(colorName: (annotation.colorName) )).withAlphaComponent(1)
    
    annotationView!.markerTintColor = pointColor
    
    if annotation.pointType == .start {
        annotationView!.glyphImage = UIImage(systemName: "ant")
    } else {
        annotationView!.glyphImage = UIImage(systemName: "checkmark.circle")
    }
    
    return annotationView!
    
}

class PointAnnotation: NSObject, MKAnnotation {
    
    let point: Point
    
    var coordinate: CLLocationCoordinate2D
    var title: String? = ""
    var subtitle: String? = ""
    
    init(point: Point, coordinate: CLLocationCoordinate2D) {
        
        self.point = point
        self.coordinate = coordinate
        
    }
    
}

func setupPointAnnotationView(for annotation: PointAnnotation, on mapView: MKMapView) -> MKAnnotationView {

    printTest(#function)
    
    let identifier = "Point"
    var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

    if annotationView == nil {
        annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        annotationView!.canShowCallout = false
    } else {
        annotationView!.annotation = annotation
        printTest("reuse annotation")
    }
    
    let pointColor = UIColor(Color.getColorFromName(colorName: (annotation.point.color) )).withAlphaComponent(1)
    
    annotationView!.markerTintColor = pointColor
    
    return annotationView!
    
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
