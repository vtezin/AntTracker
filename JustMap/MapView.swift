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
    
    @Binding var showCurrentLocation: Bool
    @Binding var span: MKCoordinateSpan
    
    @Binding var needChangeMapView: Bool
    
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
