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
    
    //work whith points
    @State var selectedPoint: Point?
    @State var showPointEdit = false
    @State var pointsWasChanged = false
    
    let minSpan: Double = 0.0008
    let maxSpan: Double = 108
    
    //Core Data
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Point.entity(), sortDescriptors: []) var points: FetchedResults<Point>
    
    //current location & track
    @EnvironmentObject var clManager: LocationManager
    @EnvironmentObject var currentTrack: GeoTrack
    
    //controls visibility
    @State var showRecordTrackControls = false
    @State var showPointsManagment = false
      
    //track
    @State var showAlertForTrackTittle = false
    @State var showQuestionBeforeResetTrack = false
 
    //animations
    @State var rotateCount: Double = 0
    
    //other
    @State private var firstAppearDone = false
    @State var isNavigationBarHidden: Bool = true
    @State private var showFullCLInfo = false //TODO remove in future
    
    var body: some View {
        
        NavigationView{
            
            VStack{
                
                //track info
                
                if clManager.trackRecording || currentTrack.points.count > 0 {
                    
                    TrackInfo(geoTrack: currentTrack, showingSavedTrack: false)
                        .padding()
                    
                }
                
                
                ZStack{
                    
                    MapView(mapType: $mapType, center: $center, span: $span, followCL: $followCL, currentLocation: $clManager.location, mapChangedByButton: $needChangeMapView, followingCurLocation: $followCL, points: points, selectedPoint: $selectedPoint, showingPointDetails: $showPointEdit, pointsWasChanged: $pointsWasChanged)
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
                            buttonTrackReset
                            Spacer()
                            buttonTrackSave
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
            
//            VStack{
//
//                ZStack {
//
//                    //first layer - map
//
//                    MapView(mapType: $mapType, center: $center, span: $span, followCL: $followCL, currentLocation: $clManager.location, mapChangedByButton: $needChangeMapView, followingCurLocation: $followCL, points: points, selectedPoint: $selectedPoint, showingPointDetails: $showPointEdit, pointsWasChanged: $pointsWasChanged)
//
//
//                    if showPointsManagment {
//
//                        Image(systemName: "plus")
//                            .imageScale(.large)
//                            .foregroundColor(globalParameters.pointControlsColor)
//                            .font(Font.title.weight(.light))
//
//                    }
//
//                    // layer 2 - track controls + cur.location info
//                    VStack{
//
//                        // track controls
//                        if showRecordTrackControls {
//
//                            VStack {
//
//                                HStack{
//                                    buttonTrackList
//                                        .padding(.leading)
//                                    Spacer()
//                                    TrackInfo(geoTrack: currentTrack, showingSavedTrack: false)
//                                    Spacer()
//                                    buttonTrackPlayPause
//                                        .padding(.trailing)
//                                }
//                                .padding(.top)
//
//                                HStack {
//
//                                    if currentTrack.points.count > 0 && !clManager.trackRecording {
//
//                                        if currentTrack.trackCoreData == nil
//                                            || currentTrack.points.count != currentTrack.trackCoreData!.trackPointsArray.count {
//
//                                            buttonTrackSave
//                                            Spacer()
//
//                                        } else {
//
//                                            if currentTrack.trackCoreData != nil {
//
//                                                HStack{
//                                                    Text(currentTrack.title)
//                                                    Text("saved")
//                                                        .font(.footnote)
//                                                        .foregroundColor(.secondary)
//                                                }
//                                                Spacer()
//
//                                            }
//
//                                        }
//
//                                        buttonTrackReset
//
//
//                                    }
//                                    else {
//                                        Spacer()
//                                    }
//
//                                }
//                                .padding(.trailing)
//                                .padding(.leading)
//                                .padding(.bottom)
//
//                            }
//                            .modifier(MapControlColors())
//                            .transition(.move(edge: .top))
//                            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
//                                        .onEnded({ value in
//                                            if value.translation.height < 0 {
//                                                withAnimation {
//                                                    showRecordTrackControls = false
//                                                }
//                                            }
//                                        }))
//
//                        }
//
//                        Spacer()
//
//                    }
//
//                    // layer 3 - controls
//
//                    HStack{
//
//                        //left - additional controls
//                        VStack{
//
//                            Spacer()
//
//                            buttonAppSettings
//
//                            buttonMapType
//
//                        }
//                        .padding()
//
//                        Spacer()
//
//                        //right
//                        VStack{
//
//                            // zoom/loc
//
//                            Spacer()
//                            Spacer()
//
//                            buttonZoomIn
//                            buttonZoomOut
//                                .padding(.top)
//
//                            Spacer()
//
//                            buttonCurLocation
//
//                        }
//                        .padding()
//
//                    }
//
//                }
//
//
//                //bottom pane
//                HStack {
//
//                    buttonTrackRecording
//
//                    Spacer()
//
//                    if !showPointsManagment {
//                        currentLocationInfo()
//                    } else {
//                        //pointsManagmentPane()
//                    }
//
//                    Spacer()
//
//                    buttonPointsManagement
//
//                }
//
//            }

            .navigationBarTitle("Map", displayMode: .inline)
            .navigationBarHidden(isNavigationBarHidden)
            .onAppear {
                
                isNavigationBarHidden = true
                
                if !firstAppearDone {
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        center = clManager.region.center
                        needChangeMapView = true
                    }
                    
                    mapType = lastUsedMapType == "hybrid" ? .hybrid : .standard
                    
                    firstAppearDone = true
                    
                }
                
            }
            
            .sheet(isPresented: $showPointEdit) {
                
                PointEdit(point: $selectedPoint, coordinate: center, pointsWasChanged: $pointsWasChanged)
                    .environmentObject(clManager)
                
            }
            
            .alert(isPresented: $showAlertForTrackTittle,
                   TextAlert(title: "Track title",
                             message: "",
                             text: Date().dateString(),
                             keyboardType: .default) { result in
                    if let text = result {
                        currentTrack.saveNewTrackToDB(title: text, moc: moc)
                    }
                   })
            
            .alert(isPresented: $showQuestionBeforeResetTrack) {
                Alert(title: Text("Reset current track?"),
                      message: Text(currentTrack.trackCoreData == nil ? "" : "(the saved track will remain in the database)"),
                      primaryButton: .destructive(Text("Reset")) {
                    
                    clManager.trackRecording = false
                    currentTrack.reset()
                    
                }, secondaryButton: .cancel())
            }
            
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
        
    }
    
    func zoomMultiplikator() -> Double {
        
        if span.latitudeDelta < 0.05 {
            return 3
        } else {
            return 5
        }
        
    }
    
    let antAnimation = Animation.easeInOut.speed(0.5).repeatForever(autoreverses: true)
    
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
                            
                            NavigationLink(destination: CoordinatesSharing(isNavigationBarHidden: $isNavigationBarHidden, coordinate: clManager.location.coordinate)) {
                                
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
                withAnimation {
                    showFullCLInfo.toggle()
                }
            }
        
    }
    
    
    
}


//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
