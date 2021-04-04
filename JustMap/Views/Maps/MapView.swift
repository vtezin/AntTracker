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
    
    @EnvironmentObject var clManager: LocationManager
    
//    @Environment(\.managedObjectContext) var moc
//    @FetchRequest(entity: Track.entity(), sortDescriptors: [], predicate: NSPredicate(format: "showOnMap == %@", true)) var tracks:FetchedResults<Track>
    
    func showSavedTracks() {
        
    }
    
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
        
        if mapChangedByButton || followingCurLocation {
            let region = MKCoordinateRegion(center: center, span: span)
            view.setRegion(region, animated: true)
        }

        if clManager.currentTrack.points.count == 0 && view.overlays.count > 0 {
            let overlays = view.overlays
            view.removeOverlays(overlays)
        }
        
        let trackPoints = clManager.currentTrack.accuracyPoints(maxAccuracy: 10)
        
        if clManager.trackRecording
        {
            
            view.addTrackLine(trackPoints: trackPoints, title: "current track")
            
        }
        
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
                
                let pr = MKPolylineRenderer(overlay: overlay)
                
                var color = UIColor(Color.getColorFromName(colorName: "orange"))
                
                if overlay.title == "current track" {
                    pr.lineWidth = 4
                } else {
                    //saved track
                    color = UIColor(Color.getColorFromName(colorName: (overlay.subtitle ?? "orange") ?? "orange")).withAlphaComponent(0.5)
                    pr.lineWidth = 3
                }
                
                pr.strokeColor = color
                
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
