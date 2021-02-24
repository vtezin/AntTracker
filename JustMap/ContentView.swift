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
    @StateObject private var manager = LocationManager()
    
    var body: some View {
        
        MapView(mapType: mapType, center: manager.region.center, wasFirstChangeVR: false, showCurrentLocation: $showCurrentLocation)
            .edgesIgnoringSafeArea(.top)
            .toolbar {
                
                ToolbarItem(placement: .bottomBar) {
                    
                    Button(action: {
                        if mapType == .standard {
                            mapType = .hybrid
                        } else {
                            mapType = .standard
                        }
                        
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
                        showCurrentLocation = true
                    }) {
                        HStack{
                            Image(systemName: showCurrentLocation ? "location.fill" : "location")
                                .font(.title)
                        }
                    }
                    
                }
                
                
            }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
