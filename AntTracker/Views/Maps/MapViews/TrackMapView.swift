//
//  TrackMapView.swift
//  JustMap
//
//  Created by test on 04.04.2021.
//

import SwiftUI
import MapKit

struct TrackMapView: UIViewRepresentable {
    
    var track: Track
    
    @Binding var mapType: MKMapType
    
    func makeUIView(context: UIViewRepresentableContext<TrackMapView>) -> MKMapView {
       
        print(#function)
        
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.mapType = mapType
        
        let statistics = track.newGetStatictic()
        
        let center = statistics.centerPoint
        let maxDist = max(statistics.distFromWestToEast, statistics.distFromNorthToSouth)
        
        print("\(statistics.centerPoint) max dist \(maxDist)")
        
        let region = MKCoordinateRegion(center: center,
                                        latitudinalMeters: maxDist * 1.5,
                                        longitudinalMeters: maxDist * 1.5)
        
        mapView.setRegion(region, animated: false)
        
        mapView.userTrackingMode = .none
        mapView.showsUserLocation = true
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsBuildings = true
        
        mapView.register(TrackPointAnnotation.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(TrackPointAnnotation.self))
        
        mapView.addTrackLine(trackPoints: statistics.points,
                             trackTitle: track.title,
                             trackColor: track.color)
        
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: UIViewRepresentableContext<TrackMapView>) {
        
        view.mapType = mapType
        
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        
        var parent: TrackMapView

        init(_ parent: TrackMapView) {
            self.parent = parent
        }
        
        //rendering track
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
                        
            if (overlay is MKPolyline) {
                if let trackPolilyne = overlay as? MKPolyline{
                    return setTrackOverlayRenderer(trackPolilyne: trackPolilyne)
                }
            }
            
            return MKOverlayRenderer()
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            //TODO similar function in MapView
            
            guard !annotation.isKind(of: MKUserLocation.self) else {
                    // Make a fast exit if the annotation is the `MKUserLocation`, as it's not an annotation view we wish to customize.
                    return nil
                }
            
            var annotationView: MKAnnotationView?
            
            if let annotation = annotation as? TrackPointAnnotation{
                annotationView = annotation.setAnnotationView(on: mapView)
            } else {
                annotationView = setAnnotationView(annotation: annotation)
            }
            
            return annotationView
            
        }
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    
}

//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView(mapType: .standard)
//    }
//}
