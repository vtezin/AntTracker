//
//  MapView.swift
//  JustMap
//
//  Created by test on 24.02.2021.
//

import SwiftUI
import MapKit

final class WrappedMap: MKMapView, UIGestureRecognizerDelegate {
    
    var onLongPress: (CLLocationCoordinate2D, MKMapView) -> Void = { _,_  in }
    var onDragOrPan: (MKMapView) -> Void = { _ in }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer is UIPanGestureRecognizer || gestureRecognizer is UIRotationGestureRecognizer) {
            return true
        } else {
            return false
        }
    }
    
    init() {
        
        super.init(frame: .zero)
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress(sender:)))
        longPressGestureRecognizer.minimumPressDuration = 0.8
        addGestureRecognizer(longPressGestureRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGesture(sender:)))
        panGestureRecognizer.minimumNumberOfTouches = 1
        panGestureRecognizer.maximumNumberOfTouches = 1
        panGestureRecognizer.delegate = self
        
        addGestureRecognizer(panGestureRecognizer)
        
    }
    
    
    @objc func onLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let location = sender.location(in: self)
            let coordinate = convert(location, toCoordinateFrom: self)
            onLongPress(coordinate, self)
            makeVibration()
        }
    }
    
    @objc func panGesture(sender: UIPanGestureRecognizer) {
        if sender.state == .ended {
            onDragOrPan(self)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}




struct MapView: UIViewRepresentable {
    
    @Binding var mapType: MKMapType
    
    //center & span
    @Binding var center: CLLocationCoordinate2D
    @Binding var span: MKCoordinateSpan
    
    var points: FetchedResults<Point>
    
    @Binding var showPointsOnTheMap: Bool
    @Binding var followCLbyMap: Bool
    @Binding var showPointsManagment: Bool
    
    //working with point selection
    @Binding var activePage: ContentView.pages
    
    @EnvironmentObject var clManager: LocationManager
    @EnvironmentObject var currentTrack: CurrentTrack
    @EnvironmentObject var appVariables: AppVariables
    
    func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
       
        let mapView = WrappedMap()
        
        mapView.onLongPress = onLongPress
        mapView.onDragOrPan = onDragOrPanMapByUser
        
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
    
    func onDragOrPanMapByUser(mapView: MKMapView) {
        //print("map dragged by user")
        followCLbyMap = false
        
    }
    
    func onLongPress(coordinate: CLLocationCoordinate2D, mapView: MKMapView) {
        
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        mapView.setRegion(region, animated: true)
        showPointsManagment = true
        followCLbyMap = false
                
    }

    func updateUIView(_ view: MKMapView, context: UIViewRepresentableContext<MapView>) {
        
        view.mapType = mapType
        
        if appVariables.needChangeMapView {
            
            let region = MKCoordinateRegion(center: center, span: span)
            view.setRegion(region, animated: span.latitudeDelta < 0.1)
            //print("span: \(span)")
            
            appVariables.needChangeMapView = false
        }
        
        if view.overlays.count > 0 && currentTrack.points.count == 0 {
            removeCurrentTrackFromMapView(mapView: view)
        }

        if clManager.trackRecordingState == .recording || (view.overlays.count == 0 && currentTrack.points.count > 0 )
        {
            view.addTrackLine(trackPoints: currentTrack.points,
                              trackTitle: "current track",
                              trackColor: currentTrackColorName())
        }
        
        
        //updating points
        if appVariables.needRedrawPointsOnMap {
            updatePointsAnnotationsOnMapView(view)
        }
        
        printTest("overlays: \(view.overlays.count)")
        printTest("annotations: \(view.annotations.count)")
        
    }
    
    func updatePointsAnnotationsOnMapView(_ view: MKMapView) {
                
        if appVariables.needRedrawPointsOnMap {
            removePointAnnotationsFromMapView(view)
            appVariables.needRedrawPointsOnMap = false
        }
        
        guard showPointsOnTheMap else { return }
        
        //FIXME: use .flatMap for filtering points annotations
        
        let foundedAnnotations = view.annotations.filter{
            
            if $0 is PointAnnotation{
                return true
            }
            return false
        }
        
        let pointsForShowing = points.filter {
            $0.pointGroup == nil || $0.pointGroup?.showOnMap ?? false
        }
        
        guard pointsForShowing.count != foundedAnnotations.count else {return}
        
        printTest("points added \(pointsForShowing.count) - \(foundedAnnotations.count)")
        
        var pointsAnnotationsOnMap = [PointAnnotation]()
        
        for foundedAnnotation in foundedAnnotations{
            pointsAnnotationsOnMap.append(foundedAnnotation as! PointAnnotation)
        }
        
        var annotationsForAdd = [PointAnnotation]()
        
        for point in pointsForShowing {
            
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
            parent.appVariables.centerOfMap = mapView.region.center
            parent.span = mapView.region.span
            
            if parent.appVariables.needChangeMapView {
                parent.appVariables.needChangeMapView = false
            }
            
            if let selectedPoint = parent.appVariables.selectedPoint {
                
                if !mapView.visibleMapRect.contains(MKMapPoint(selectedPoint.coordinate))
                {
                    withAnimation {
                        parent.appVariables.selectedPoint = nil
                    }
                }
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
            
            if annotation.isKind(of: MKUserLocation.self) {
                
//                if parent.clManager.location.horizontalAccuracy > 50 {
//
//                    return nil
//
//                } else {
                    
                    let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "UserLocation")
                    return annotationView
                    
//                }
                
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
        
//        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//
//            guard let placemark = view.annotation as? PointAnnotation else { return }
//            parent.appVariables.selectedPoint = placemark.point
//
//            withAnimation{
//                parent.activePage = ContentView.pages.editPoint
//            }
//
//        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

            if let placemark = view.annotation as? PointAnnotation {
                
                withAnimation{
                    parent.appVariables.selectedPoint = placemark.point
                    parent.followCLbyMap = false
                }
                mapView.deselectAnnotation(placemark, animated: true)
                
                let center = CLLocationCoordinate2D(latitude: placemark.point.latitude, longitude: placemark.point.longitude)
                
                let region = MKCoordinateRegion(center: center, span: parent.span)
                
                mapView.setRegion(region, animated: true)

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
