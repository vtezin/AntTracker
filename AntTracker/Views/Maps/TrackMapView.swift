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
       
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.mapType = mapType
        
        let geoTrack = GeoTrack(track: track)
        let center = geoTrack.centerPoint!
        let distFromWestToEast = geoTrack.westPoint!.distance(from: geoTrack.eastPoint!)
        let distFromNorthToSouth = geoTrack.northPoint!.distance(from: geoTrack.southPoint!)
        
        let maxDist = max(distFromWestToEast, distFromNorthToSouth)
        
        let region = MKCoordinateRegion(center: center,
                                        latitudinalMeters: maxDist * 1.5,
                                        longitudinalMeters: maxDist * 1.5)
        
        mapView.setRegion(region, animated: false)
        
        mapView.userTrackingMode = .none
        mapView.showsUserLocation = true
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsBuildings = true
        
        mapView.addTrackLine(trackPoints: geoTrack.points, title: track.title, subtitle: track.color, showStartFinish: true)
        
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
            return setAnnotationView(annotation: annotation, showFinish: true)
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
