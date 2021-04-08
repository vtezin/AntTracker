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
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var clManager: LocationManager
    @EnvironmentObject var currentTrack: GeoTrack
    
    @State private var showRecordTrackControls = false
    @State private var showAdditionalControls = false
    @State private var followCL = false
    
    @State var isNavigationBarHidden: Bool = true
    
    @State private var showFullCLInfo = false
        
    @State private var showAlertForTrackTittle = false
    
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
                
                // layer 2 - track info
                
                VStack{
                    
                    // panel
                    
                    if showRecordTrackControls {
                        
                        VStack {
                            
                            HStack{
                                TrackInfo(geoTrack: currentTrack)
                            }
                            
                            HStack {
                                
                                NavigationLink(destination: TrackListView(isNavigationBarHidden: $isNavigationBarHidden)) {
                                    
                                    Image(systemName: "tray.full")
                                        .font(Font.title.weight(.light))
                                    
                                }
                                
                                Spacer()
                                
                                if currentTrack.points.count > 0 && !clManager.trackRecording {
                                    
                                    if currentTrack.trackCoreData == nil
                                        || currentTrack.points.count != currentTrack.trackCoreData!.trackPointsArray.count {
                                        
                                        buttonTrackSave
                                        Spacer()
                                        
                                    } else {
                                        
                                        if currentTrack.trackCoreData != nil {
                                        
                                            HStack{
                                                Text(currentTrack.trackCoreData!.title)
                                                Text("saved")
                                            }
                                            Spacer()
                                            
                                        }
                                        
                                    }
                                    
                                    
                                    buttonTrackReset
                                    Spacer()
                                    
                                }
                                else {
                                    Spacer()
                                }
                                
                                
                                buttonTrackPlayPause
                                
                                
                            }

                        }
                        
                        .modifier(MapControl())
                        .transition(.move(edge: .top))
                        
                    }
                    
                    Spacer()
                    
                    currentLocationInfo()
                        .padding()
                    
                }
                
                
                
                // layer 3 - controls
                HStack{
                    
                    //left - additional controls
                    VStack{
                        
                        Spacer()
                        
                        if showAdditionalControls {
                            
                            VStack{
                                
                                Image(systemName: "gear")
                                    .modifier(MapButton())
                                    .onTapGesture {
                                        
                                       showAlertForTrackTittle = true
                                        
                                    }
                                
                                Image(systemName: mapType == .standard ? "globe" : "map")
                                    .modifier(MapButton())
                                    .onTapGesture {
                                        mapType = mapType == .standard ? .hybrid : .standard
                                        needChangeMapView = true
                                    }
                                
                                
//                                Image(systemName: "mappin.and.ellipse")
//                                    .modifier(MapButton())
                            }
                            .transition(.move(edge: .leading))
                            
                        }
                        
                        
                            buttonTrackRecording
                        
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
            }
            .ignoresSafeArea(.all)
            
            .alert(isPresented: $showAlertForTrackTittle,
                   TextAlert(title: "Track title",
                             message: "",
                             keyboardType: .default) { result in
                    if let text = result {
                        currentTrack.saveNewTrackToDB(title: text, moc: moc)
                    } else {
                        
                    }
                   })
            
        }
        
    }
    
    
    func currentLocationInfo() -> some View {
        
        let gpsAccuracy = Int(clManager.location.horizontalAccuracy)
        
        var colorAccuracy = Color.red
        
        switch gpsAccuracy {
        case ..<20:
            colorAccuracy = Color.systemBackground
        case 20..<100:
            colorAccuracy = Color.yellow
        default:
            colorAccuracy = Color.red
        }
        
        return
            
            HStack {
                
                VStack{
                    Text(clManager.location.speedKmH + " " + "km/h")
                        .font(.body)
                    if gpsAccuracy > 10 || showFullCLInfo {
                        Text("gps +/- \(gpsAccuracy) m")
                    }
                    if showFullCLInfo {
                        VStack{
                            Text("\(clManager.location.latitude)")
                            Text("\(clManager.location.longitude)")
                            Text("alt." + String(format: "%.0f", clManager.location.altitude) + " " + "m")
                        }
                    }
                    
                }
                .font(.caption)
                
//                if showFullCLInfo {
//                    Image(systemName: "square.and.arrow.up")
//                        .font(Font.title.weight(.light))
//                        .padding(5)
//                }
                
            }
            .foregroundColor(.primary)
            .padding(5)
            .background(colorAccuracy.opacity(0.5).clipShape(RoundedRectangle(cornerRadius: 5)))
            .onTapGesture()
            {
                withAnimation {
                    showFullCLInfo.toggle()
                }
            }
        
    }
    
    var buttonTrackRecording: some View {
        
        //Image(systemName: "arrow.triangle.swap")
        Image(systemName: "ant")
            .modifier(MapButton())
            .rotationEffect(.degrees(clManager.trackRecording ? 90 : 0))
            //.scaleEffect(clManager.trackRecording ? 1.2 : 1)
            .animation(.easeInOut)
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
                            lineWidth: showRecordTrackControls ? 3 : 0)
            )
        
    }
    
    
    var buttonTrackPlayPause: some View {
        
        Image(systemName: clManager.trackRecording ? "pause.circle" : "play.circle")
            .font(Font.largeTitle.weight(.light))
            .onTapGesture() {
                withAnimation{
                    clManager.trackRecording.toggle()
                }
            }
        
    }
    
    var buttonTrackReset: some View {
        
        Image(systemName: "xmark.circle")
            .font(Font.title.weight(.light))
            .onTapGesture() {
                clManager.trackRecording = false
                currentTrack.reset()
            }
        
    }
    
    var buttonTrackSave: some View {
        
        Image(systemName: "square.and.arrow.down")
            .font(Font.title.weight(.light))
            .onTapGesture() {
                
                if currentTrack.trackCoreData == nil {
                   
                    //save new track
                    showAlertForTrackTittle = true
                    
                } else {
                    //update current track
                    currentTrack.updateTrackInDB(moc: moc)
                }
                
            }
        
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
