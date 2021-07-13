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
    
    var points: FetchedResults<Point>
    
    @Binding var showPointsOnTheMap: Bool
    
    //working with point selection
    @Binding var activePage: ContentView.pages
    
    @EnvironmentObject var clManager: LocationManager
    @EnvironmentObject var currentTrack: CurrentTrack
    @EnvironmentObject var constants: GlobalAppVars
    
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
        
        mapView.register(TrackPointAnnotation.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(TrackPointAnnotation.self))
        
        return mapView
        
    }

    func updateUIView(_ view: MKMapView, context: UIViewRepresentableContext<MapView>) {
        
        view.mapType = mapType
        
        if constants.needChangeMapView {
            
            let region = MKCoordinateRegion(center: center, span: span)
            view.setRegion(region, animated: true)
            
            constants.needChangeMapView = false
        }
        
        if view.overlays.count > 0 && currentTrack.points.count == 0 {
            removeCurrentTrackFromMapView(mapView: view)
        }

        if clManager.trackRecording || (view.overlays.count == 0 && currentTrack.points.count > 0 )
        {
            view.addTrackLine(trackPoints: currentTrack.points,
                              trackTitle: "current track",
                              trackColor: currentTrackColorName())
        }
        
        
        //updating points
        if constants.needRedrawPointsOnMap {
            updatePointsAnnotationsOnMapView(view)
        }
        
        printTest("overlays: \(view.overlays.count)")
        printTest("annotations: \(view.annotations.count)")
        
    }
    
    func updatePointsAnnotationsOnMapView(_ view: MKMapView) {
                
        if constants.needRedrawPointsOnMap {
            removePointAnnotationsFromMapView(view)
            constants.needRedrawPointsOnMap = false
        }
        
        guard showPointsOnTheMap else { return }
        
        //FIXME: use .flatMap for filtering points annotations
        
        let foundedAnnotations = view.annotations.filter{
            
            if $0 is PointAnnotation{
                return true
            }
            return false
        }
        
        guard points.count != foundedAnnotations.count else {return}
        
        printTest("points added \(points.count) - \(foundedAnnotations.count)")
        
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
        
        if annotationsForAdd.count > 0 {
            view.addAnnotations(annotationsForAdd)
        }
        
    }
    
    func removePointAnnotationsFromMapView(_ view: MKMapView) {
        
        let foundedAnnotations = view.annotations.filter{
            
            if $0 is PointAnnotation{
                return true
            }
            return false
        }
        
        
        view.removeAnnotations(foundedAnnotations)
        
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            
            parent.center = mapView.region.center
            parent.constants.centerOfMap = mapView.region.center
            parent.span = mapView.region.span
            
            if parent.constants.needChangeMapView {
                parent.constants.needChangeMapView = false
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
        
        func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
            
            parent.clManager.addHeadingAnnotation(didAdd: views)

        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            guard !annotation.isKind(of: MKUserLocation.self) else {
                
                //return nil
                let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "UserLocation")
                return annotationView
                
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
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            
            guard let placemark = view.annotation as? PointAnnotation else { return }
            
            parent.constants.editingPoint = placemark.point
            
            withAnimation{
                parent.activePage = ContentView.pages.editPoint
            }
            
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            
            if let placemark = view.annotation as? PointAnnotation {
                
                parent.constants.editingPoint = placemark.point
                mapView.deselectAnnotation(placemark, animated: true)
                withAnimation{
                    parent.activePage = ContentView.pages.editPoint
                }
                
            }  else if ((view.annotation?.isKind(of: MKUserLocation.self)) != nil) {
                
                mapView.deselectAnnotation(view.annotation, animated: true)
                
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
