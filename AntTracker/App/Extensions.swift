//
//  Extensions.swift
//  JustMap
//
//  Created by test on 25.03.2021.
//

import Foundation
import SwiftUI
import CoreData
import MapKit

extension Date {
    
    static var smallestDate: Date {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.date(from: "1800/01/01")!
        
    }
    
    func dateString() -> String {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
        
    }
    
    func timeString() -> String {
        
        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .short
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
        
    }
    
}

extension Color {
    
    public static func getColorFromName(colorName: String) -> Color {
        
        switch colorName {
        case "blue":
            return Color.blue
        case "green":
            return Color.green
        case "red":
            return Color.red
        case "gray":
            return Color.gray
        case "orange":
            return Color.orange
        case "purple":
            return Color.purple
        default:
            return Color.orange
        }
        
    }
    
    static var systemBackground: Color {
        Color(UIColor.systemBackground)
    }
    
}

extension BinaryFloatingPoint {
    var dms: (degrees: Int, minutes: Int, seconds: Int) {
        var seconds = Int(self * 3600)
        let degrees = seconds / 3600
        seconds = abs(seconds % 3600)
        return (degrees, seconds / 60, seconds % 60)
    }
}

extension CLLocation {
    
    var dms: String { latitude + " " + longitude }
    var latitude: String {
        let (degrees, minutes, seconds) = coordinate.latitude.dms
        return String(format: "%d°%d'%d\"%@", abs(degrees), minutes, seconds, degrees >= 0 ? "N" : "S")
    }
    var longitude: String {
        let (degrees, minutes, seconds) = coordinate.longitude.dms
        return String(format: "%d°%d'%d\"%@", abs(degrees), minutes, seconds, degrees >= 0 ? "E" : "W")
    }
    
    var speedKmH: String {
        
        if speed <= 0 {
            return "0"
        }
        
        let doubleSpeed = Double(speed)
        //convert to km/h
        let doubleSpeedKmH = doubleSpeed/1000 * 60 * 60
        return String(format: "%.1f", doubleSpeedKmH)
        
    }
    
}

extension CLLocationSpeed {
    
    var doubleKmH: Double {
        return self/1000 * 60 * 60
    }
    
}

extension Double {
    
    var string2s: String {
        return String(format: "%.2f", self)
    }
    
}

extension MKMapView {
    
    func addTrackLine(geoTrack: GeoTrack, title: String, subtitle: String, showStartFinish: Bool) {
        
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

        
        //removing old overlay
        
        for overlay in overlays {
            if overlay.title == title {
                removeOverlays([overlay])
            }
        }
        
        addOverlays([polyline])
        
        if showStartFinish {
            
            //adding start point
                
            let startPoint = trackPoints.first!
            
            let startAnnotation = MKPointAnnotation()
            
            startAnnotation.title = startPoint.location.timestamp.dateString()
            startAnnotation.subtitle = "Start"
            startAnnotation.coordinate = startPoint.location.coordinate
            
            let finishPoint = trackPoints.last!
            
            let finishAnnotation = MKPointAnnotation()
            
            finishAnnotation.title = finishPoint.location.timestamp.timeString()
            finishAnnotation.subtitle = "Finish"
            finishAnnotation.coordinate = finishPoint.location.coordinate
            
            //removeAnnotations(annotations)
            addAnnotations([startAnnotation, finishAnnotation])
            
        }
    
    }
    
}

func setAnnotationView(annotation:MKAnnotation, showFinish: Bool) -> MKAnnotationView? {
    
    if annotation.subtitle == "Start" {
        
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")

        annotationView.markerTintColor = UIColor(red: (69.0/255), green: (95.0/255), blue: (170.0/255), alpha: 1.0)
        
        return annotationView
        
    } else if showFinish && annotation.subtitle == "Finish" {
      
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
