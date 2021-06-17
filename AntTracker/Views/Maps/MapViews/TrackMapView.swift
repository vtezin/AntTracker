//
//  TrackMapView.swift
//  JustMap
//
//  Created by test on 04.04.2021.
//

import SwiftUI
import MapKit

struct TrackMapView: UIViewRepresentable {
    
    let statistics: TrackStatistic
    let trackTitle: String
    let trackColor: String
    
    @Binding var mapType: MKMapType
    
    func makeUIView(context: UIViewRepresentableContext<TrackMapView>) -> MKMapView {
       
        printTest(#function)
        
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.mapType = mapType
        
        let maxDist = max(statistics.distFromWestToEast, statistics.distFromNorthToSouth)
        let region = MKCoordinateRegion(center: statistics.centerPoint,
                                        latitudinalMeters: maxDist * 1.5,
                                        longitudinalMeters: maxDist * 1.5)
        
        
        mapView.setRegion(region, animated: false)
        
        mapView.userTrackingMode = .none
        mapView.showsUserLocation = true
        mapView.showsScale = true
        mapView.showsCompass = true
        mapView.showsBuildings = true
        
        mapView.register(TrackPointAnnotation.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(TrackPointAnnotation.self))
        
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: UIViewRepresentableContext<TrackMapView>) {
        
        printTest(#function)
        
        view.mapType = mapType
        
        if view.overlays.count == 0 {
            print("addTrackLine points \(statistics.points.count)")
            view.addTrackLine(trackPoints: statistics.points,
                              trackTitle: trackTitle,
                              trackColor: trackColor)
        }
        
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
            
            //FIXME: similar function in MapView
            
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
