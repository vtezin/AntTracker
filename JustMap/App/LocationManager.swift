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
            UIApplication.shared.isIdleTimerDisabled = trackRecording
        }
    }
    
    @Published var currentTrack : GeoTrack
    
    override init() {
        
        self.currentTrack = GeoTrack()
        self.trackRecording = false
        
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.activityType = .fitness
        manager.showsBackgroundLocationIndicator = true
        manager.startUpdatingLocation()
        manager.startUpdatingHeading()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.last.map {
            let center = CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            
            location = $0
            region = MKCoordinateRegion(center: center, span: span)
            
            if trackRecording && Int(location.horizontalAccuracy) <= 10 {
                
                //print("\($0.coordinate)")
//                if currentTrack.points.count > 0 {
//                    print("\($0.distance(from: currentTrack.points.last!))")
//                }
                
                currentTrack.points.append($0)
                
                
            }
            
        }
        
    }
    
    
}


