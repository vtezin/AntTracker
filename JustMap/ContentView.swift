//
//  ContentView.swift
//  JustMap
//
//  Created by test on 24.02.2021.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    @State private var mapType: MKMapType = .hybrid
    @State private var showCurrentLocation = true
    @State private var center = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    @State private var span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    @State private var needChangeMapView = false
    
    let minSpan: Double = 0.0008
    let maxSpan: Double = 108
    
    @StateObject private var clManager = LocationManager()
    
    var body: some View {
        
        ZStack {
            
            MapView(mapType: mapType, center: $center, wasFirstChangeVR: false, showCurrentLocation: $showCurrentLocation, span: $span, needChangeMapView: $needChangeMapView)
                .edgesIgnoringSafeArea(.top)
            
            VStack {
                
                HStack {
                 
                    Image(systemName: mapType == .standard ? "globe" : "map")
                        .modifier(MapButton())
                        .font(nil)
                        .onTapGesture(count: 1) {
                            if mapType == .standard {
                                mapType = .hybrid
                            } else {
                                mapType = .standard
                            }

                            needChangeMapView = true
                        }
                    
                    Spacer()
                    
                }
                .padding()
                
                Spacer()
                
                HStack {
                    

                    
                    Spacer()
                    
                    Image(systemName: "minus")
                        .modifier(MapButton())
                        .onTapGesture(count: 2) {
                            let newDelta = min(span.latitudeDelta * 4, maxSpan)
                            
                            span = MKCoordinateSpan(latitudeDelta: newDelta,
                                                    longitudeDelta: newDelta)
                            
                            needChangeMapView = true
                        }
                        .onTapGesture(count: 1) {
                            let newDelta = min(span.latitudeDelta * 2, maxSpan)
                            
                            span = MKCoordinateSpan(latitudeDelta: newDelta,
                                                    longitudeDelta: newDelta)
                            
                            needChangeMapView = true
                        }
                    
                    
                    Image(systemName: mapShowsCurrentLocation() ? "location" : "location")
                        .modifier(MapButton())
                        .onTapGesture(count: 2) {
                            span = MKCoordinateSpan(latitudeDelta: minSpan * 2,
                                                    longitudeDelta: minSpan * 2)
                            center = clManager.region.center
                            needChangeMapView = true
                        }
                        .onTapGesture(count: 1) {
                            center = clManager.region.center
                            needChangeMapView = true
                        }
                    
                    Image(systemName: "plus")
                        .modifier(MapButton())
                        .onTapGesture(count: 2) {
                            let newDelta = max(span.latitudeDelta/4, minSpan)
                            span = MKCoordinateSpan(latitudeDelta: newDelta,
                                                    longitudeDelta: newDelta)
                            needChangeMapView = true
                        }
                        .onTapGesture(count: 1) {
                            let newDelta = max(span.latitudeDelta/2, minSpan)
                            span = MKCoordinateSpan(latitudeDelta: newDelta,
                                                    longitudeDelta: newDelta)
                            needChangeMapView = true
                        }
                    
                }
                .padding()
            }
            
            
        }
        
        

        
        
        
        
    }
    
    func mapShowsCurrentLocation() -> Bool {
        
        return true
        
    }
    
    func zoomMultiplikator() -> Double {
        
        //print("\(span.latitudeDelta)")
        
        if span.latitudeDelta < 0.05 {
            return 3
        } else {
            return 6
        }
        
    }
    

}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
