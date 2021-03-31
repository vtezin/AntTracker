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
    @State private var showAdditionalControls = false
    @State private var followCL = false
    
    @State var isNavigationBarHidden: Bool = true
    
    @State private var showFullCLInfo = false
        
    var body: some View {
        
        NavigationView{
            
            ZStack {
                
                //first layer - map
                VStack {
                    
                    if followCL {
                        MapView(mapType: $mapType, center: $clManager.region.center, span: $span, currentLocation: $clManager.location, mapChangedByButton: $needChangeMapView, followingCurLocation: $followCL)
                        
                    } else {
                        
                        MapView(mapType: $mapType, center: $center, span: $span, currentLocation: $clManager.location, mapChangedByButton: $needChangeMapView, followingCurLocation: $followCL)
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
                        
                        TrackControlsView(isNavigationBarHidden: $isNavigationBarHidden,
                                          locationManager: clManager)
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
                        
                        //if showTrackRecordingButton{
                            buttonTrackRecording
                        //}
                        
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
                                    
                                    //Spacer()
                                    
                                    
                                }
                                
                            }
                            
                        }
                        
                        
                        
                    }
                    .padding()
                    
                }
                
                
            }
            .navigationBarTitle("Map", displayMode: .inline)
            .navigationBarHidden(isNavigationBarHidden)
            .onAppear {
                isNavigationBarHidden = true
                print("on appear")
            }
            .ignoresSafeArea(.all)
            
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
        
        return
            
            HStack {
                
                VStack{
                    Text("gps +/- \(gpsAccuracy) m")
                    if showFullCLInfo {
                        Text("\(clManager.location.latitude)")
                        Text("\(clManager.location.longitude)")
                        Text("alt." + String(format: "%.0f", clManager.location.altitude) + " m")
                    }
                    
                }
                .font(.caption)
                
                if showFullCLInfo {
                    Image(systemName: "square.and.arrow.up")
                        .font(Font.title.weight(.light))
                        .padding(5)
                        .onTapGesture()
                        {
                            print("share position")
                        }
                }
                
            }
            .foregroundColor(.primary)
            .padding(5)
            .background(colorAccuracy.opacity(0.7).clipShape(RoundedRectangle(cornerRadius: 5)))
            .onTapGesture()
            {
                showFullCLInfo.toggle()
            }
        
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
                    .stroke(Color.systemBackground,
                            lineWidth: clManager.trackRecording ? 3 : 0)
            )
        
    }
    
    var buttonZoomIn: some View {
        
        Image(systemName: "plus")
            .modifier(MapButton())
            .onTapGesture() {
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
            
            .onTapGesture() {
                
                let newDelta = min(span.latitudeDelta * zoomMultiplikator(), maxSpan)
                
                span = MKCoordinateSpan(latitudeDelta: newDelta,
                                        longitudeDelta: newDelta)
                showAdditionalControls = false
                needChangeMapView = true
                
            }
        
    }
    
    var buttonCurLocation: some View {
        
        Image(systemName: "location.north")
            .modifier(MapButton())
            .overlay(
                Circle()
                    .stroke(Color.systemBackground,
                            lineWidth: followCL ? 3 : 0)
            )
            
//            .onTapGesture(count: 2) {
//                followCL.toggle()
//                needChangeMapView = true
//                showAdditionalControls = false
//            }
            
            .onTapGesture() {
                center = clManager.region.center
                needChangeMapView = true
                showAdditionalControls = false
            }
        
            .onLongPressGesture {
                followCL.toggle()
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
