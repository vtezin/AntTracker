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
    @Published var heading: CLLocationDirection?
    @Published var headingAnnotationImageView: UIImageView
    
    var rotateHeadingAnnotation = false
    
    private let manager = CLLocationManager()
    
    @Published var trackRecording: Bool {
        didSet {
            manager.allowsBackgroundLocationUpdates = trackRecording
        }
    }
    
    override init() {
        
        self.trackRecording = false
    
        let image = UIImage(systemName: "location.north.fill")!
            .withTintColor(#colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1))
            .withRenderingMode(.alwaysTemplate)
        
        headingAnnotationImageView = UIImageView(image: image)
        
        super.init()
        
        //headingAnnotationImageView.image = image
        headingAnnotationImageView.frame = CGRect(x: 0, y: 0, width: image.size.width * 1.5, height: image.size.height * 1.5)
        
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
            
            if trackRecording {
                DispatchQueue.global(qos: .utility).sync{ [weak self] in
                    CurrentTrack.currentTrack.addNewPointFromLocation(location: self!.location)
                }
            }
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if newHeading.headingAccuracy < 0 { return }
        
        let heading = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
        self.heading = heading
        
        if rotateHeadingAnnotation {
            headingAnnotationImageView.transform = CGAffineTransform(rotationAngle: CGFloat(heading * .pi / 180))
        }
        
    }
    
    func addHeadingAnnotation(didAdd views: [MKAnnotationView]) {
        
        if views.last?.annotation is MKUserLocation {
            
            let annotationView = views.last!
            addHeadingAnnotationSubview(to: annotationView)
            
        } else {
            
            for annotationView in views {
                if annotationView.annotation is MKUserLocation{
                    addHeadingAnnotationSubview(to: annotationView)
                }
            }
            
        }
        
    }
    
    func addHeadingAnnotationSubview(to annotationView: MKAnnotationView) {
        
        rotateHeadingAnnotation = false
        
        headingAnnotationImageView.transform = CGAffineTransform(rotationAngle: CGFloat(0))
        
        headingAnnotationImageView.frame = CGRect(x: (annotationView.frame.size.width - headingAnnotationImageView.frame.size.width)/2, y: (annotationView.frame.size.height - headingAnnotationImageView.frame.size.height)/2, width: headingAnnotationImageView.frame.size.width, height: headingAnnotationImageView.frame.size.height)
        
        annotationView.insertSubview(headingAnnotationImageView, at: 0)
        
        rotateHeadingAnnotation = true
        
    }
    
    
}


