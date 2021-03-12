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
    @State private var center = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    @State private var span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    @State private var needChangeMapView = false
    @State private var stateAddingPOI = false
    
    let minSpan: Double = 0.0008
    let maxSpan: Double = 108
    
    @StateObject private var clManager = LocationManager()
    
    @State private var showRecordTrackControls = false
    @State private var trackRecordingMode = TrackRecordingModes.stop
    
    var body: some View {
        
        ZStack {
            
            VStack {
                
                MapView(mapType: mapType, center: $center, wasFirstChangeVR: false, span: $span, needChangeMapView: $needChangeMapView, currentTrack: $clManager.currentTrack)
                    .edgesIgnoringSafeArea(.top)
                
            }
            
            VStack{
                
                //top
                HStack {
                    
                    Image(systemName: mapType == .standard ? "globe" : "map")
                        .modifier(MapButton())
                        .onTapGesture(count: 1) {
                            if mapType == .standard {
                                mapType = .hybrid
                            } else {
                                mapType = .standard
                            }
                            
                            needChangeMapView = true
                        }
                    
                    Spacer()
                    
                    Image(systemName: "gear")
                    .modifier(MapButton())
                    
                }.padding()
                
                Spacer()
                
                //center
                HStack {
                    
                    Spacer()
                    
                    VStack{
                        
                        Spacer()
                        
                        Image(systemName: "plus")
                            .modifier(MapButton())
                            .font(.title)
                            .onTapGesture() {
                                let newDelta = max(span.latitudeDelta/zoomMultiplikator(), minSpan)
                                span = MKCoordinateSpan(latitudeDelta: newDelta,
                                                        longitudeDelta: newDelta)
                                needChangeMapView = true
                            }
                        
                        Image(systemName: "minus")
                            .modifier(MapButton())
                            .font(.title)
                            .padding(.top)
                            .onTapGesture() {
                                let newDelta = min(span.latitudeDelta * zoomMultiplikator(), maxSpan)
                                
                                span = MKCoordinateSpan(latitudeDelta: newDelta,
                                                        longitudeDelta: newDelta)
                                
                                needChangeMapView = true
                            }
                        
                        Spacer()
                        
                        Image(systemName: mapShowsCurrentLocation() ? "location" : "location")
                            .modifier(MapButton())
                            .font(.title)
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
                        Text(" +/- \(Int(clManager.location.horizontalAccuracy)) m")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(5)
                            .background(Color(UIColor.systemBackground).opacity(0.5).clipShape(RoundedRectangle(cornerRadius: 5)))
                        
                    }
                    
                    
                }
                .padding(.horizontal)
                
                Spacer()
                
                //bottom
                HStack {
                    
                    VStack{
                        
                        Image(systemName: "mappin.and.ellipse")
                            .modifier(MapButton())
                            .onTapGesture() {
                                stateAddingPOI = true
                            }
                        
                        Image(systemName: "arrow.triangle.swap")
                            .modifier(MapButton())
                            .onTapGesture()
                            {
                                withAnimation {
                                    showRecordTrackControls.toggle()
                                }
                                
                            }
                            .overlay(
                                    Circle()
                                        .stroke(Color(UIColor.systemBackground), lineWidth: showRecordTrackControls ? 2 : 0)
                                )
                    }
                    
                    if showRecordTrackControls {
                        
                        HStack {
                            Spacer()
                            TrackControlsView(recordingMode: $trackRecordingMode, locationManager: clManager)
                                .modifier(MapControl())
                            Spacer()
                        }
                        
                    } else {
                        Spacer()
                    }
                    
                    //Spacer()
                    
                }.padding()
                
                
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
