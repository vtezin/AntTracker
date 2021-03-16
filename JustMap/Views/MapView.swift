//
//  MapView.swift
//  JustMap
//
//  Created by test on 24.02.2021.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    
    @Binding var mapType: MKMapType
    
    //center & span
    @Binding var center: CLLocationCoordinate2D
    @Binding var span: MKCoordinateSpan
    
    //current location
    @Binding var currentLocation: CLLocation
    
    //track visualisation
    @Binding var currentTrack: Track
        
    @Binding var needChangeMapView: Bool
    @Binding var fixCenterMapAtCL: Bool
    
    
    func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
       
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.mapType = mapType
        
        //let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: false)
        
        mapView.userTrackingMode = .none
        mapView.showsUserLocation = true
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsBuildings = true
    
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: UIViewRepresentableContext<MapView>) {
        
        view.mapType = mapType

            //var span = view.region.span
            //current span = view.region.span
        
        if needChangeMapView {
            let region = MKCoordinateRegion(center: center, span: span)
            view.setRegion(region, animated: true)
        }

        if currentTrack.points.count == 0 && view.overlays.count > 0 {
            let overlays = view.overlays
            view.removeOverlays(overlays)
        }
        
        if currentTrack.points.count - 1 > view.overlays.count {

            let oldCoordinates = currentTrack.points[currentTrack.points.count - 2].coordinate
            let newCoordinates = currentTrack.points[currentTrack.points.count - 1].coordinate
            var area = [oldCoordinates, newCoordinates]
            let polyline = MKPolyline(coordinates: &area, count: area.count)
            view.addOverlay(polyline)
            
        }
        
        //print("track: \(currentTrack.points.count), overlays: \(view.overlays.count)")
        
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            
            //print(#function)
            
//            if parent.fixCenterMapAtCL {
//                let clCenter = CLLocationCoordinate2D(latitude: parent.currentLocation.coordinate.latitude,
//                                                      longitude: parent.currentLocation.coordinate.longitude)
//
//                parent.center = clCenter
//                parent.needChangeMapView = true
//
//            }
            
            parent.span = mapView.region.span
            parent.center = mapView.region.center
            
            if parent.needChangeMapView {
                parent.needChangeMapView = false
            }
            
        }
        
        //rendering track
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
                        
            if (overlay is MKPolyline) {
                
                let pr = MKPolylineRenderer(overlay: overlay)
                pr.strokeColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
                pr.lineWidth = 3
                return pr
            }
            
            return MKOverlayRenderer()
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