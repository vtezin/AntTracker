//
//  LocationManager.swift
//  JustMap
//
//  Created by test on 24.02.2021.
//

import Foundation
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var region = MKCoordinateRegion()
    @Published var location = CLLocation()
    
    private let manager = CLLocationManager()
    
    @Published var trackRecording: Bool {
        didSet {
            manager.allowsBackgroundLocationUpdates = trackRecording
        }
    }
    @Published var currentTrack : CurrentTrack
    
    override init() {
        
        self.currentTrack = CurrentTrack()
        self.trackRecording = false
        
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.last.map {
            let center = CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            
            location = $0
            region = MKCoordinateRegion(center: center, span: span)
            
            if trackRecording && Int(location.horizontalAccuracy) <= 10 {
                //print("\($0.coordinate)")
                currentTrack.points.append($0)
            }
            
            
        }
        
    }
    
    
}

extension CLLocation {
    
    func speedKmH() -> String {
        
        let doubleSpeed = Double(self.speed)
        //convert to km/h
        let doubleSpeedKmH = doubleSpeed/1000 * 60 * 60
        return String(format: "%.2f", doubleSpeedKmH)
        
    }
    
}

extension CLLocationSpeed {
    
    func doubleKmH() -> Double {
        return self/1000 * 60 * 60
    }
    
}

extension Double {
    
    func string2s() -> String {
        return String(format: "%.2f", self)
    }
    
}
