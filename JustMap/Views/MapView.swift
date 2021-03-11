//
//  MapView.swift
//  JustMap
//
//  Created by test on 24.02.2021.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    
    let mapType: MKMapType
    //let region: MKCoordinateRegion
    @Binding var center: CLLocationCoordinate2D
    var wasFirstChangeVR: Bool
    //@Binding var center: CLLocationCoordinate2D
    
    @Binding var span: MKCoordinateSpan
    @Binding var needChangeMapView: Bool
    @Binding var currentTrack: Track
    
    func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
       
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.mapType = mapType
        
        //let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: false)
        
        mapView.userTrackingMode = .follow
        mapView.showsUserLocation = true
        mapView.showsScale = true

        return mapView
    }

    func updateUIView(_ view: MKMapView, context: UIViewRepresentableContext<MapView>) {
        
        view.mapType = mapType
        
        if needChangeMapView {
            
            //var span = view.region.span
            
            //current span = view.region.span
            //let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: center, span: span)
            view.setRegion(region, animated: true)
            
            view.userTrackingMode = .none
            
            
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
            if parent.wasFirstChangeVR {
                parent.needChangeMapView = true
            }
            parent.wasFirstChangeVR = true
            parent.span = mapView.region.span
            parent.center = mapView.region.center
            
            if parent.needChangeMapView {
                parent.needChangeMapView = false
            }
            
        }
        
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
                        
            if (overlay is MKPolyline) {
                
                let pr = MKPolylineRenderer(overlay: overlay)
                pr.strokeColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
                pr.lineWidth = 5
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
