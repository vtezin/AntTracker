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
    @AppStorage("lastUsedMapType") var lastUsedMapType: String = "hybrid"
    
    @State private var center = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    @State private var span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    @State private var needChangeMapView = false
    
    let minSpan: Double = 0.0008
    let maxSpan: Double = 108
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Point.entity(), sortDescriptors: []) var points: FetchedResults<Point>
    
    @EnvironmentObject var clManager: LocationManager
    @EnvironmentObject var currentTrack: GeoTrack
    
    @State private var showRecordTrackControls = false
    @State private var followCL = false
    @State private var showSavedTracks = false
    
    @State private var showPointsManagment = false
    @State private var selectedPoint: Point?
    @State private var showPointEdit = false
    @State private var pointsWasChanged = false
    
    @State var isNavigationBarHidden: Bool = true
    
    @State private var showFullCLInfo = false
        
    @State private var showAlertForTrackTittle = false
    
    @State private var showQuestionBeforeResetTrack = false
    @State private var firstAppearDone = false
    
    @State private var rotateCount: Double = 0
    
    var body: some View {
        
        NavigationView{
            
            VStack{
            
                ZStack {
                    
                    //first layer - map
                    
                    MapView(mapType: $mapType, center: $center, span: $span, followCL: $followCL, currentLocation: $clManager.location, mapChangedByButton: $needChangeMapView, followingCurLocation: $followCL, points: points, selectedPoint: $selectedPoint, showingPointDetails: $showPointEdit, pointsWasChanged: $pointsWasChanged)
                    
                    
                    if showPointsManagment {
                        
                        Image(systemName: "plus")
                            .imageScale(.large)
                            .foregroundColor(globalParameters.pointControlsColor)
                            .font(Font.title.weight(.light))
                        
                    }
                    
                    // layer 2 - track controls + cur.location info
                    VStack{
                        
                        // track controls
                        if showRecordTrackControls {
                            
                            VStack {
                                
                                HStack{
                                    buttonTrackList
                                        .padding(.leading)
                                    Spacer()
                                    TrackInfo(geoTrack: currentTrack, showStartFinishDates: false)
                                    Spacer()
                                    buttonTrackPlayPause
                                        .padding(.trailing)
                                }
                                .padding(.top)
                                
                                HStack {
                                    
                                    if currentTrack.points.count > 0 && !clManager.trackRecording {
                                        
                                        if currentTrack.trackCoreData == nil
                                            || currentTrack.points.count != currentTrack.trackCoreData!.trackPointsArray.count {
                                            
                                            buttonTrackSave
                                            Spacer()
                                            
                                        } else {
                                            
                                            if currentTrack.trackCoreData != nil {
                                                
                                                HStack{
                                                    Text(currentTrack.title)
                                                    Text("saved")
                                                        .font(.footnote)
                                                        .foregroundColor(.secondary)
                                                }
                                                Spacer()
                                                
                                            }
                                            
                                        }
                                        
                                        buttonTrackReset
                                        
                                        
                                    }
                                    else {
                                        Spacer()
                                    }
                                    
                                }
                                .padding(.trailing)
                                .padding(.leading)
                                .padding(.bottom)
                                
                            }
                            .modifier(MapControlColors())
                            .transition(.move(edge: .top))
                            .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                        .onEnded({ value in
                                            if value.translation.height < 0 {
                                                withAnimation {
                                                    showRecordTrackControls = false
                                                }
                                            }
                                        }))
                            
                        }
                        
                        Spacer()
                        
                    }
                    
                    // layer 3 - controls
                    
                    HStack{
                        
                        //left - additional controls
                        VStack{
                            
                            Spacer()
                            
                            NavigationLink(destination: AppSettings(isNavigationBarHidden: $isNavigationBarHidden)) {
                                Image(systemName: "gearshape")
                                    .modifier(MapButton())
                            }
                            
                            Button(action: {
                                mapType = mapType == .standard ? .hybrid : .standard
                                lastUsedMapType = mapType == .standard ? "standart" : "hybrid"
                                needChangeMapView = true
                            }) {
                                Image(systemName: mapType == .standard ? "globe" : "map")
                            }
                            .modifier(MapButton())
                            
                        }
                        .padding()
                        
                        Spacer()
                        
                        //right
                        VStack{
                            
                            // zoom/loc
                            
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
                    
                }
                
                
                //bottom pane
                HStack {
                    
                    buttonTrackRecording
                    
                    Spacer()
                    
                    if !showPointsManagment {
                        currentLocationInfo()
                    } else {
                        pointsManagmentPane()
                    }
                    
                    Spacer()
                    
                    buttonPointsManagement
                    
                }
            
            }

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
                
                PointEdit(point: selectedPoint, coordinate: center, pointsWasChanged: $pointsWasChanged)
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
    
    
    func pointsManagmentPane() -> some View {
        
        return

            HStack{
                
                Button(action: {
                    
                    selectedPoint = nil
                    showPointEdit = true
                    showPointsManagment = false
                    
                }) {
                    Image(systemName: "star")
                       .modifier(ControlButton())
                }
                
//                HStack{
//                    Image(systemName: "arrow.right.to.line.alt")
//                    Text(localeDistanceString(distanceMeters: clManager.location.distance(from: CLLocation(latitude: center.latitude, longitude: center.longitude))))
//                }
//                .font(.caption)
                
//                NavigationLink(destination: CoordinatesSharing(isNavigationBarHidden: $isNavigationBarHidden, coordinate: center)) {
//
//                    Image(systemName: "square.and.arrow.up")
//                        .modifier(ControlButton())
//
//                }
                
            }
            .foregroundColor(globalParameters.pointControlsColor)
        
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
    
    
    var buttonTrackList: some View {
        
        NavigationLink(destination: TrackListView(isNavigationBarHidden: $isNavigationBarHidden, showSavedTracks: $showSavedTracks)) {
            
            Image(systemName: "tray.full")
                .modifier(ControlButton())
            
        }
        
    }
    
    var buttonTrackPlayPause: some View {
        
        Button(action: {
            withAnimation{
                clManager.trackRecording.toggle()
            }
        }) {
            Image(systemName: clManager.trackRecording ? "pause" : "play")
                .modifier(ControlButton())
        }
        
    }
    
    var buttonTrackReset: some View {
        
        Button(action: {
            showQuestionBeforeResetTrack = true
        }) {
            Image(systemName: "xmark")
                .modifier(ControlButton())
        }
        
    }
    
    var buttonTrackSave: some View {
        
        Button(action: {
            
            if currentTrack.trackCoreData == nil {
                //save new track
                showAlertForTrackTittle = true
            } else {
                //update current track
                currentTrack.updateTrackInDB(moc: moc)
            }

            
        }) {
            Image(systemName: "tray.and.arrow.down")
                .modifier(ControlButton())
        }
        
        
    }
    
    var buttonTrackRecording: some View {
        
        Button(action: {
            withAnimation {
                showRecordTrackControls.toggle()
            }
            
        }) {
            Image(systemName: "ant")
                .modifier(MapButton())
                .rotationEffect(.degrees(clManager.trackRecording ? 90 : 0))
                //.scaleEffect(clManager.trackRecording ? 1.2 : 1)
                //.animation(.easeInOut)
                .overlay(
                    Circle()
                        .stroke(Color.systemBackground,
                                lineWidth: showRecordTrackControls ? 4 : 0)
                )
        }
        
    }
    
    let antAnimation = Animation.easeInOut.speed(0.5).repeatForever(autoreverses: true)
    
    var buttonPointsManagement: some View {
        
        Button(action: {
            withAnimation {
                showPointsManagment.toggle()
            }
            
        }) {
            Image(systemName: "mappin.and.ellipse")
                .modifier(MapButton())
                .foregroundColor(showPointsManagment ? globalParameters.pointControlsColor : .primary)
            
        }
        
    }
    
    
    var buttonZoomIn: some View {
        
        Button(action: {
            let newDelta = max(span.latitudeDelta/zoomMultiplikator(), minSpan)
            span = MKCoordinateSpan(latitudeDelta: newDelta,
                                    longitudeDelta: newDelta)
            needChangeMapView = true
            
        }) {
            Image(systemName: "plus")
                .modifier(MapButton())
        }
        //.disabled(span.latitudeDelta == minSpan)
        
    }
    
    var buttonZoomOut: some View {
        
        Button(action: {
            let newDelta = min(span.latitudeDelta * zoomMultiplikator(), maxSpan)
            
            span = MKCoordinateSpan(latitudeDelta: newDelta,
                                    longitudeDelta: newDelta)
            needChangeMapView = true
            
        }) {
            
            ZStack {

                //for same sizes all buttons
                Image(systemName: "plus")
                    .opacity(0.0)

                Image(systemName: "minus")

            }
            .modifier(MapButton())

        }
        //.disabled(span.latitudeDelta == maxSpan)
        
    }
    
    var buttonCurLocation: some View {
        
        //Image(systemName: followCL ? "location.viewfinder" : "location")
        Image(systemName: "location")
            .modifier(MapButton())
            .overlay(
                Circle()
                    .stroke(Color.systemBackground,
                            lineWidth: followCL ? 5 : 0)
            )
            .rotationEffect(.radians(2 * Double.pi * rotateCount))
            .animation(.easeOut)
            
            .onTapGesture() {
                center = clManager.region.center
                needChangeMapView = true
                rotateCount += 1
            }
        
            .onLongPressGesture {
                followCL.toggle()
                center = clManager.region.center
                needChangeMapView = true
            }
        
    }
    
    
    func zoomMultiplikator() -> Double {
        
        if span.latitudeDelta < 0.05 {
            return 2
        } else {
            return 4
        }
        
    }
    
    
}


//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
