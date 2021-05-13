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
    @Binding var mapChangedByButton: Bool
    @Binding var followingCurLocation: Bool
    @Binding var showSavedTracks: Bool
    
    @EnvironmentObject var clManager: LocationManager
    @EnvironmentObject var currentTrack: GeoTrack
    
    @Environment(\.managedObjectContext) var moc
//    @FetchRequest(entity: Track.entity(), sortDescriptors: [], predicate: NSPredicate(format: "showOnMap == %@", true)) var tracks: FetchedResults<Track>
    @FetchRequest(entity: Track.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Track.startDate, ascending: false)]) var tracks:FetchedResults<Track>
    
    func showSavedTracks(view: MKMapView) {
        
        for track in tracks {
            view.addTrackLine(track:track, geoTrack: nil)
        }
        
    }
    
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
        
        //mapView.register(TrackPointAnnotation.self, forAnnotationViewWithReuseIdentifier: "trackPoint")
        
        if showSavedTracks {
            showSavedTracks(view: mapView)
        }
        
        return mapView
        
    }

    func updateUIView(_ view: MKMapView, context: UIViewRepresentableContext<MapView>) {
        
        view.mapType = mapType
        
        if mapChangedByButton || followingCurLocation {
            let region = MKCoordinateRegion(center: center, span: span)
            view.setRegion(region, animated: true)
            mapChangedByButton = false
        }

        if currentTrack.points.count == 0 {
            removeCurrentTrackFromMapView(mapView: view)
        } else {
            
            
        }

        if clManager.trackRecording || (view.overlays.count == 0 && currentTrack.points.count > 0 )
        {
            view.addTrackLine(track: nil, geoTrack: currentTrack)
        }
        
        //print(view.annotations.count)
        
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
                annotationView = setupTrackPointAnnotationView(for: annotation, on: mapView)
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
