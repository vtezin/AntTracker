//
//  ContentView.swift
//  JustMap
//
//  Created by test on 24.02.2021.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    //map bindings
    @State var mapType: MKMapType = .hybrid
    @AppStorage("lastUsedMapType") var lastUsedMapType: String = "hybrid"
    @State var center = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    @State var span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    @State var needChangeMapView = false
    @State var followCL = false
    @State var followCLforTimer = false
    
    //work whith points
    @State var selectedPoint: Point?
    @State var showPointEdit = false
    
    let minSpan: Double = 0.0008
    let maxSpan: Double = 108
    
    //Core Data
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Point.entity(), sortDescriptors: []) var points: FetchedResults<Point>
    
    //current location & track
    @EnvironmentObject var clManager: LocationManager
    @EnvironmentObject var currentTrack: GeoTrack
    //constants
    @EnvironmentObject var constants: Constants
    
    //controls visibility
    @State var showRecordTrackControls = false
    @State var showPointsManagment = false
    
    //track
    @State var showQuestionBeforeResetTrack = false
    
    //animations
    @State var rotateCount: Double = 0
    
    //other
    @State private var firstAppearDone = false
    @State private var showFullCLInfo = false //TODO remove in future
    
    //sheets support
    enum sheetModes: Identifiable {
        
        var id: Int {hashValue}
        
        case editPoint
        case saveTrack
        
    }
    @State var sheetMode: sheetModes?
    
    //pages support
    enum pages: Identifiable {
        var id: Int {hashValue}
        case map
        case tracks
        case appSettings
    }
    @State var activePage: pages = .map
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        
        switch activePage {
        
        case .map:
            
            VStack{
                
                //track info
                
                if clManager.trackRecording || currentTrack.points.count > 0 {
                    
                    TrackInfo(geoTrack: currentTrack, showingSavedTrack: false)
                        .padding()
                    
                }
                
                
                ZStack{
                    
                    MapView(mapType: $mapType, center: $center, span: $span, points: points, selectedPoint: $selectedPoint, sheetMode: $sheetMode)
                        .onReceive(timer) { _ in
                            if followCLforTimer {
                                center = clManager.region.center
                                constants.needChangeMapView = true
                            }
                        }
                    //.edgesIgnoringSafeArea(.all)
                    
                    //map controls layer
                    HStack{
                        
                        VStack{
                            Spacer()
                            buttonMapType
                        }
                        .padding()
                        
                        Spacer()
                        
                        VStack{
                            Spacer()
                            Spacer()
                            buttonZoomIn
                            buttonZoomOut
                                .padding(.top)
                            Spacer()
                            buttonCurLocation
                        }
                        .padding()
                        
                    }
                    
                    if showPointsManagment {
                        Image(systemName: "plus")
                            .imageScale(.large)
                            .font(Font.title.weight(.light))
                            .foregroundColor(.orange)
                    }
                    
                    if followCLforTimer {
                        Image(systemName: "escape")
                            .imageScale(.large)
                            .font(Font.title.weight(.light))
                            .foregroundColor(.blue)
                            .rotationEffect(.degrees((clManager.heading ?? 0) + 45))
                    }
                    
                }
                
                //info
                
                //controls
                HStack{
                    
                    if showRecordTrackControls {
                        
                        buttonBackToMainControls
                        Spacer()
                        buttonTrackPlayPause
                        Spacer()
                        
                        if !clManager.trackRecording && currentTrack.points.count > 0 {
                            buttonTrackSave
                            Spacer()
                            buttonTrackReset
                        }
                        
                        
                    }
                    else if showPointsManagment {
                        
                        buttonBackToMainControls
                        Spacer()
                        buttonAddPoint
                        Spacer()
                        buttonAddPointFromClipboard
                        
                        
                    }
                    else {
                        
                        buttonTrackRecording
                        Spacer()
                        buttonTrackList
                        Spacer()
                        buttonPointsManagement
                        Spacer()
                        buttonAppSettings
                        
                        
                    }
                    
                }
                .padding()
                
            }
            
            .onAppear {
                
                if !firstAppearDone {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        center = clManager.region.center
                        constants.needChangeMapView = true
                    }
                    
                    mapType = lastUsedMapType == "hybrid" ? .hybrid : .standard
                    
                    firstAppearDone = true
                    
                }
                
            }
            
            .sheet(item: $sheetMode) { mode in
                
                switch mode {
                case .editPoint:
                    PointEdit(point: $selectedPoint, coordinate: center)
                        .environmentObject(clManager)
                case .saveTrack:
                    TrackPropertiesView(track: nil, currentTrack: currentTrack, mapSettingsChanged: $needChangeMapView)
                        .environment(\.managedObjectContext, moc)
                }
                
            }
            
            .alert(isPresented: $showQuestionBeforeResetTrack) {
                Alert(title: Text("Reset current track?"),
                      message: Text(currentTrack.trackCoreData == nil ? "" : "(the saved track will remain in the database)"),
                      primaryButton: .destructive(Text("Reset")) {
                        
                        clManager.trackRecording = false
                        currentTrack.reset()
                        
                      }, secondaryButton: .cancel())
            }
            
        case.tracks:
            
            TrackListView(activePage: $activePage)
        
        case.appSettings:
            
            AppSettings(activePage: $activePage)            
            
        }
        
    }


func zoomMultiplikator() -> Double {
    
    if span.latitudeDelta < 0.05 {
        return 3
    } else {
        return 5
    }
    
}

//let antAnimation = Animation.easeInOut.speed(0.5).repeatForever(autoreverses: true)

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
            
            if showFullCLInfo {
                
                HStack {
                    
                    VStack{
                        Text("\(clManager.location.latitudeDMS)")
                        Text("\(clManager.location.longitudeDMS)")
                        Text("alt." + String(format: "%.0f", clManager.location.altitude) + " " + "m")
                    }
                    
                    NavigationLink(destination: CoordinatesSharing(coordinate: clManager.location.coordinate)) {
                        
                        Image(systemName: "square.and.arrow.up")
                            .font(Font.title.weight(.light))
                    }
                    
                }
                
            } else {
                
                VStack{
                    
                    Text(clManager.location.speed.localeSpeedString)
                        .font(.body)
                    if gpsAccuracy > 10 || showFullCLInfo {
                        Text("gps +/- \(gpsAccuracy) m")
                    }
                    
                }
                
            }
            
        }
        .font(.caption)
        .foregroundColor(.primary)
        .padding(5)
        .background(colorAccuracy.opacity(0.7).clipShape(RoundedRectangle(cornerRadius: 5)))
        .onTapGesture()
        {
            //withAnimation {
            showFullCLInfo.toggle()
            //}
        }
    
}
}


//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
