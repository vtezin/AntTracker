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
    
    let minSpan: Double = 0.0008
    let maxSpan: Double = 108
    
    @EnvironmentObject var clManager: LocationManager // environment object
    
    @State private var showRecordTrackControls = false
    @State private var trackRecordingMode = TrackRecordingModes.stop
    @State private var showAdditionalControls = false
    @State private var followCL = false
    
    var body: some View {
        
        ZStack {
            
            VStack {
                
                if followCL {
                    MapView(mapType: $mapType, center: $clManager.region.center, span: $span, currentLocation: $clManager.location, currentTrack: $clManager.currentTrack, mapChangedByButton: $needChangeMapView, followCL: $followCL)
                    
                } else {
                    
                    MapView(mapType: $mapType, center: $center, span: $span, currentLocation: $clManager.location, currentTrack: $clManager.currentTrack, mapChangedByButton: $needChangeMapView, followCL: $followCL)
                }
                
                    //.edgesIgnoringSafeArea(.top)
                
            }
            .onAppear(perform: {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    center = clManager.region.center
                    needChangeMapView = true
                    //print("\(clManager.region.center)")
                }
                
            })
            
            
            HStack{
                
                //left - additional controls
                VStack{
                    
                    Spacer()
                    
                    if showAdditionalControls {
                        
                        Image(systemName: "gear")
                            .modifier(MapButton())
                        
                        Image(systemName: mapType == .standard ? "globe" : "map")
                            .modifier(MapButton())
                            .onTapGesture(count: 1) {
                                                                
                                mapType = mapType == .standard ? .hybrid : .standard
                                needChangeMapView = true
                                
                            }
                        
                        Image(systemName: "mappin.and.ellipse")
                            .modifier(MapButton())
                        
                        Image(systemName: "arrow.triangle.swap")
                            .modifier(MapButton())
                            .onTapGesture()
                            {
                                withAnimation {
                                    showRecordTrackControls.toggle()
                                    showAdditionalControls = false
                                }
                            }
                            .overlay(
                                    Circle()
                                        .stroke(Color(UIColor.systemBackground),
                                                lineWidth: showRecordTrackControls ? 2 : 0)
                                )
                        
                    }
                    
                    Image(systemName: showAdditionalControls ? "chevron.down" : "chevron.up")
                        .modifier(MapButton())
                        .font(.title)
                        .onTapGesture(count: 1) {
                            withAnimation {
                                showAdditionalControls.toggle()
                            }
                        }
                    
                }
                .padding()
                
                //right
                VStack{
                    
                    // zoom/loc
                    VStack{
                        
                        HStack{
                            
                            Spacer()
                            
                            VStack{
                                
                                Text(" +/- \(Int(clManager.location.horizontalAccuracy)) m")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(5)
                                    .background(Color(UIColor.systemBackground).opacity(0.5).clipShape(RoundedRectangle(cornerRadius: 5)))
                                
                                Spacer()
                                Spacer()
                                
                                buttonZoomIn
                                buttonZoomOut
                                    .padding(.top)
                                
                                Spacer()
                                
                                buttonCurLocation
                                    .modifier(MapButton())
                                    .font(.title)
                                    .overlay(
                                        Circle()
                                            .stroke(Color(UIColor.systemBackground),
                                                    lineWidth: followCL ? 2 : 0)
                                    )
                                
                                Spacer()

                                
                            }
                            
                        }
                        
                    }
                    
                    // panel
                    
                    if showRecordTrackControls {
                        
                        HStack {
                            TrackControlsView(recordingMode: $trackRecordingMode, locationManager: clManager)
                                .modifier(MapControl())
                        }
                        
                    } else {
                        Spacer()
                    }
                    
                }
                .padding()
                
            }
            
            
        }
        
        
    }
    
    var buttonZoomIn: some View {
        
        Image(systemName: "plus")
            .modifier(MapButton())
            .font(.title)
//            .onTapGesture(count: 2) {
//                span = MKCoordinateSpan(latitudeDelta: minSpan * 2,
//                                        longitudeDelta: minSpan * 2)
//                center = clManager.region.center
//                needChangeMapView = true
//            }
            .onTapGesture(count: 1) {
                let newDelta = max(span.latitudeDelta/zoomMultiplikator(), minSpan)
                span = MKCoordinateSpan(latitudeDelta: newDelta,
                                        longitudeDelta: newDelta)
                needChangeMapView = true
            }
        
    }
    
    var buttonZoomOut: some View {
        
        Image(systemName: "minus")
            .modifier(MapButton())
            .font(.largeTitle)
//            .onTapGesture(count: 2) {
//                span = MKCoordinateSpan(latitudeDelta: maxSpan / 2,
//                                        longitudeDelta: maxSpan / 2)
//                center = clManager.region.center
//                needChangeMapView = true
//            }
            .onTapGesture(count: 1) {
                
                let newDelta = min(span.latitudeDelta * zoomMultiplikator(), maxSpan)
                
                span = MKCoordinateSpan(latitudeDelta: newDelta,
                                        longitudeDelta: newDelta)
                
                needChangeMapView = true
                
            }
        
    }
    
    var buttonCurLocation: some View {
        
        Image(systemName: mapShowsCurrentLocation() ? "location" : "location")
            
            .onTapGesture(count: 2) {
                followCL.toggle()
                needChangeMapView = true
            }
            .onTapGesture(count: 1) {
                center = clManager.region.center
                needChangeMapView = true
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
