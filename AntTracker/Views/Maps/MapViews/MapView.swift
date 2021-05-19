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
    
    @Binding var mapChangedByButton: Bool
    @Binding var followingCurLocation: Bool
    
    var points: FetchedResults<Point>
    
    @EnvironmentObject var clManager: LocationManager
    @EnvironmentObject var currentTrack: GeoTrack
    
    func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
       
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.mapType = mapType
        
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
        
        if mapChangedByButton || followingCurLocation {
            let region = MKCoordinateRegion(center: center, span: span)
            view.setRegion(region, animated: true)
            mapChangedByButton = false
        }

        if view.overlays.count > 0 && currentTrack.points.count == 0 {
            removeCurrentTrackFromMapView(mapView: view)
        }

        if clManager.trackRecording || (view.overlays.count == 0 && currentTrack.points.count > 0 )
        {
            view.addTrackLine(track: nil, geoTrack: currentTrack)
        }
        
        
        //adding points
        addPointsAnnotationsToMapView(view)
        
        printTest("overlays: \(view.overlays.count)")
        printTest("annotations: \(view.annotations.count)")
        
    }
    
    func addPointsAnnotationsToMapView(_ view: MKMapView) {
        
        //TODO use .flatMap for filtering points annotations
        
        let foundedAnnotations = view.annotations.filter{
            
            if $0 is PointAnnotation{
                return true
            }
            return false
        }
        
        guard points.count != foundedAnnotations.count else {return}
        
        var pointsAnnotationsOnMap = [PointAnnotation]()
        
        for foundedAnnotation in foundedAnnotations{
            pointsAnnotationsOnMap.append(foundedAnnotation as! PointAnnotation)
        }
        
        var annotationsForAdd = [PointAnnotation]()
        
        for point in points {
            if !pointsAnnotationsOnMap.contains(where: {$0.point == point}) {
                let annotation = PointAnnotation(point: point)
                annotation.title = point.title
                annotationsForAdd.append(annotation)
            }
        }
        
        view.addAnnotations(annotationsForAdd)
        
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            
            if !parent.followingCurLocation {
                parent.center = mapView.region.center
                parent.span = mapView.region.span
            }
            
            if parent.mapChangedByButton {
                parent.mapChangedByButton = false
            }
            
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
            
            guard !annotation.isKind(of: MKUserLocation.self) else {
                // Make a fast exit if the annotation is the `MKUserLocation`, as it's not an annotation view we wish to customize.
                return nil
            }
            
            var annotationView: MKAnnotationView?
            
            if let annotation = annotation as? TrackPointAnnotation{
                annotationView = annotation.setAnnotationView(on: mapView)
            } else if let annotation = annotation as? PointAnnotation {
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
