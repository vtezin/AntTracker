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
    
    @StateObject private var clManager = LocationManager()
    
    var body: some View {
        
        MapView(mapType: mapType, center: $center, wasFirstChangeVR: false, showCurrentLocation: $showCurrentLocation, span: $span, needChangeMapView: $needChangeMapView)
            .onAppear {

            }
            .edgesIgnoringSafeArea(.top)
            .toolbar {
                
                ToolbarItem(placement: .bottomBar) {
                    
                    Button(action: {
                        if mapType == .standard {
                            mapType = .hybrid
                        } else {
                            mapType = .standard
                        }
                        
                        needChangeMapView = true
                        
                    }) {
                        HStack{
                            Image(systemName: mapType == .standard ? "globe" : "map")
                                .font(.title)
                        }
                    }
                    
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                             
                        let newDelta = max(span.latitudeDelta/zoomMultiplikator(),0.0008)
                        
                        span = MKCoordinateSpan(latitudeDelta: newDelta,
                                                longitudeDelta: newDelta)
                        needChangeMapView = true
                        
                    }) {
                        HStack{
                            Image(systemName: "plus")
                                .font(.title)
                        }
                    }
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }
                
                ToolbarItem(placement: .bottomBar) {
                    
                    Button(action: {
                                  
                        let newDelta = min(span.latitudeDelta * zoomMultiplikator(), 108)
                        
                        span = MKCoordinateSpan(latitudeDelta: newDelta,
                                                longitudeDelta: newDelta)
                        
                        needChangeMapView = true
                        
                        
                    }) {
                        HStack{
                            Image(systemName: "minus")
                                .font(.title)
                        }
                    }
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }
                
                ToolbarItem(placement: .bottomBar) {
                    
                    Button(action: {
                        showCurrentLocation = true
                        center = clManager.region.center
                        needChangeMapView = true
                    }) {
                        HStack{
                            Image(systemName: mapShowsCurrentLocation() ? "location.fill" : "location")
                                .font(.title)
                        }
                    }
                    
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
