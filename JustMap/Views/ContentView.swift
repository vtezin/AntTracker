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
            
            
            //first layer - map
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
            .onTapGesture() {
                withAnimation {
                    //showAdditionalControls = false
                    showAdditionalControls.toggle()
                }
            }
            
            // layer 2 - info
            
            VStack{
                
                // panel
                
                if showRecordTrackControls || clManager.trackRecording {
                    
                    TrackControlsView(recordingMode: $trackRecordingMode, locationManager: clManager)
                        .modifier(MapControl())
                    
                }
                
                Spacer()
                
                    gpsAccuracyInfo()
                        .padding()
                
                
            }
            
            
            
            // layer 3 - controls
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
                        
                        
                    }
                    
                    if showTrackRecordingButton{
                        buttonTrackRecording
                    }
                                        
//                    if !showAdditionalControls {
//
//                    Image(systemName: showAdditionalControls ? "chevron.down" : "chevron.up")
//                        .modifier(MapButton())
//                        .onTapGesture(count: 1) {
//                            withAnimation {
//                                showAdditionalControls.toggle()
//                            }
//                        }
//                    }
                    
                }
                .padding()
                
                //right
                VStack{
                    
                    // zoom/loc
                    VStack{
                        
                        HStack{
                            
                            Spacer()
                            
                            VStack(alignment: .trailing){
                                
                                
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
                                
                                //Spacer()

                                
                            }
                            
                        }
                        
                    }
                    
                  
                    
                }
                .padding()
                
            }
            
            
        }
        
        
    }
    
    var showTrackRecordingButton: Bool {
        return showAdditionalControls || showRecordTrackControls || clManager.trackRecording
    }
    
    func gpsAccuracyInfo() -> some View {
        
        let gpsAccuracy = Int(clManager.location.horizontalAccuracy)
        
        var colorAccuracy = Color.red
        
        switch gpsAccuracy {
        case ..<20:
            colorAccuracy = Color.green
        case 20..<100:
            colorAccuracy = Color.yellow
        default:
            colorAccuracy = Color.red
        }
        
        return Text("gps +/- \(gpsAccuracy) m")
            .font(.caption)
            .foregroundColor(.primary)
            .padding(5)
            .background(colorAccuracy.opacity(0.7).clipShape(RoundedRectangle(cornerRadius: 5)))
    }
    
    var buttonTrackRecording: some View {
        
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
                    .stroke(clManager.trackRecording ? Color.blue : Color.secondary,
                            lineWidth: clManager.trackRecording ? 3 : 0)
            )
        
    }
    
    var buttonZoomIn: some View {
        
        Image(systemName: "plus")
            .modifier(MapButton())
            .onTapGesture(count: 2) {
                span = MKCoordinateSpan(latitudeDelta: minSpan * 4,
                                        longitudeDelta: minSpan * 4)
                center = clManager.region.center
                showAdditionalControls = false
                needChangeMapView = true
            }
            .onTapGesture(count: 1) {
                let newDelta = max(span.latitudeDelta/zoomMultiplikator(), minSpan)
                span = MKCoordinateSpan(latitudeDelta: newDelta,
                                        longitudeDelta: newDelta)
                showAdditionalControls = false
                needChangeMapView = true
            }
        
    }
    
    var buttonZoomOut: some View {
        
        Image(systemName: "minus")
            .modifier(MapButton())
            
            .onTapGesture(count: 2) {
                span = MKCoordinateSpan(latitudeDelta: maxSpan / 500,
                                        longitudeDelta: maxSpan / 500)
                center = clManager.region.center
                showAdditionalControls = false
                needChangeMapView = true
            }
            
            .onTapGesture(count: 1) {

                let newDelta = min(span.latitudeDelta * zoomMultiplikator(), maxSpan)

                span = MKCoordinateSpan(latitudeDelta: newDelta,
                                        longitudeDelta: newDelta)
                showAdditionalControls = false
                needChangeMapView = true

            }
        
    }
    
    var buttonCurLocation: some View {
        
        Image(systemName: "location.north")
            
            .onTapGesture(count: 2) {
                followCL.toggle()
                needChangeMapView = true
                showAdditionalControls = false
            }
            .onTapGesture(count: 1) {
                center = clManager.region.center
                needChangeMapView = true
                showAdditionalControls = false
            }
 
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
