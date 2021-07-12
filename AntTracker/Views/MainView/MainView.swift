//
//  MainView.swift
//  AntTracker
//
//  Created by test on 07.06.2021.
//

import SwiftUI
import MapKit

struct MainView: View {
    
    @Binding var activePage: ContentView.pages
    
    @Environment(\.colorScheme) var colorScheme
    
    //map bindings
    @State var mapType: MKMapType = .hybrid
    @AppStorage("lastUsedMapType") var lastUsedMapType: String = "hybrid"
    
    @State var center = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    @State var span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    
    @State var needChangeMapView = false
    @State var followCL = false
    @State var followCLforTimer = false
    
    @AppStorage("lastUsedCLLatitude") var lastUsedCLLatitude: Double = 0
    @AppStorage("lastUsedCLLongitude") var lastUsedCLLongitude: Double = 0
    
    @SceneStorage("lastUsedMapCenterLatitude") var lastUsedMapCenterLatitude: Double = 0
    @SceneStorage("lastUsedMapCenterLongitude") var lastUsedMapCenterLongitude: Double = 0
    @SceneStorage("lastUsedMapSpan") var lastUsedMapSpan: Double = 0.01
    
    //work whith points
    @State var selectedPoint: Point?
    @AppStorage("showPointsOnTheMap") var showPointsOnTheMap = true
    //import point
    @AppStorage("lastUsedPointColor") var lastUsedPointColor: String = "orange"
    @State var coordinatesForImportPoint = ""
    @State var showGoToCoordinates = false
    @State var showInvalidFormatGoToCoordinates = false
    
    let minSpan: Double = 0.0008
    let maxSpan: Double = 108
    
    //Core Data
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Point.entity(), sortDescriptors: []) var points: FetchedResults<Point>
    
    //current location & track
    @EnvironmentObject var clManager: LocationManager
    @EnvironmentObject var currentTrack: CurrentTrack
    
    @AppStorage("currentTrackColor") var currentTrackColor: String = "orange"
    //constants
    @EnvironmentObject var appVariables: GlobalAppVars
    
    //controls visibility
    @State var showRecordTrackControls = false
    @State var showPointsManagment = false
    
    //track
    @State var showQuestionBeforeResetTrack = false
    
    //animations
    @State var rotateCount: Double = 0
    
    //other
    @AppStorage("disableAutolockScreen") var disableAutolockScreen: Bool = false
    @State var dateOfSavingCurrentTrack = Date()
    @State private var stringDistanceFromCLToCenter = ""
    
    //ant animation support
    @State var animatingProperties = AntAnimatingProperties()
    @State var animateAnt = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
            
            VStack{
                    
                if showRecordTrackControls && currentTrack.points.count > 0 {
                    
                    CurrentTrackInfo()
                        .padding()
                        .transition(.move(edge: .bottom))
                    
                }
                
                
                ZStack{
                    
                    MapView(mapType: $mapType, center: $center, span: $span, points: points, showPointsOnTheMap: $showPointsOnTheMap, activePage: $activePage)
                        .onReceive(timer) { _ in
                            if followCLforTimer {
                                moveCenterMapToCurLocation()
                            }
                            if showPointsManagment {
                                stringDistanceFromCLToCenter = localeDistanceString(distanceMeters: CLLocation(latitude: center.latitude, longitude: center.longitude).distance(from: clManager.location))
                            }
                        }
                    .edgesIgnoringSafeArea(.all)
                    
                    //map controls layer
                    
                    VStack{

                        HStack{

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

                        HStack{
                            gpsAccuracyAndSpeedInfo()
                                .padding()
                        }

                    }
                    
                    
                    if showPointsManagment {
                        VStack{
                            Image(systemName: "plus")
                                .imageScale(.large)
                                .font(Font.title.weight(.light))
                            Text(stringDistanceFromCLToCenter)
                                .font(Font.callout)
                        }
                        .foregroundColor(colorForMapText(mapType: mapType, colorScheme: colorScheme))
                    }
                    
                    if followCLforTimer {
                        Image(systemName: "escape")
                            .imageScale(.large)
                            .font(Font.title.weight(.light))
                            .foregroundColor(Color.getColorFromName(colorName: currentTrackColor))
                            .rotationEffect(.degrees((clManager.heading ?? 0) + 45))
                    }
                    
                }
                
                
                //controls
                HStack{
                    
                    if showRecordTrackControls {
                            
                        HStack{
                            
                            buttonBackToMainControls
                            Spacer()
                            buttonTrackPlayPause
                            Spacer()
                            
                            if currentTrack.points.count > 0 {
                                buttonTrackSave
                                Spacer()
                                buttonTrackReset
                            }
                            
                        }
                        
                        .transition(.move(edge: .bottom))
                        
                    }
                    else if showPointsManagment {

                        VStack{
                            if showGoToCoordinates {
                                barGoToCoordinates
                                    .padding(.init(top: 3, leading: 0, bottom: 3, trailing: 0))
                                    .transition(.move(edge: .bottom))
                            }
                            HStack{
                                buttonBackToMainControls
                                Spacer()
                                buttonAddPoint
                                Spacer()
                                buttonSharePosition
                                Spacer()
                                buttonGoToCoordinates
                            }
                        }
                        .transition(.move(edge: .bottom))
                        
                    }
                    else {
                        
                        buttonTrackRecording
                        Spacer()
                        buttonTrackList
                        Spacer()
                        buttonPointsManagement
                        Spacer()
                        buttonOptions
                        
                    }
                    
                }
                .padding(.init(top: 3, leading: 15, bottom: 3, trailing: 15))
                
            }
            
            .onAppear {
                
                UIApplication.shared.isIdleTimerDisabled = disableAutolockScreen
                
                if lastUsedMapCenterLatitude != 0  {
                    
                    //restore saved state
                    
                    center = CLLocationCoordinate2D(latitude: lastUsedMapCenterLatitude,
                                                    longitude: lastUsedMapCenterLongitude)
                    
                    span = MKCoordinateSpan(latitudeDelta: lastUsedMapSpan,
                                            longitudeDelta: lastUsedMapSpan)
                                        
                } else {
                    
                    let clReceived = clManager.region.center.latitude != 0
                        || clManager.region.center.longitude != 0
                    
                    let lastUsedCLReceived = lastUsedCLLongitude != 0
                        && lastUsedCLLatitude != 0
                    
                    if clReceived {
                        moveCenterMapToCurLocation()
                    } else {
                        //try to restore last coordinates
                        if lastUsedCLReceived {
                            let lastUsedLocation = CLLocationCoordinate2D(latitude: lastUsedCLLatitude, longitude: lastUsedCLLongitude)
                            center = lastUsedLocation
                        } else {
                            //try to get CL after 0.5 sec
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                moveCenterMapToCurLocation()
                            }
                            
                        }
                    }
                    
                }
                
                mapType = lastUsedMapType == "hybrid" ? .hybrid : .standard
                appVariables.needChangeMapView = true
                appVariables.needRedrawPointsOnMap = true
                
            }
            
            .onDisappear{
                //save app storages
                lastUsedMapCenterLatitude = center.latitude
                lastUsedMapCenterLongitude = center.longitude
                lastUsedMapSpan = span.latitudeDelta
            }
            
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                if clManager.trackRecording {
                    moveCenterMapToCurLocation()
                }
            }
            
            .alert(isPresented: $showQuestionBeforeResetTrack) {
                Alert(title: Text("Reset current track?"),
                      primaryButton: .destructive(Text("Reset")) {
                        
                        moveCenterMapToCurLocation()
                        withAnimation{
                            
                            clManager.trackRecording = false
                            
                            if let trackCD = currentTrack.trackCoreData {
                                Track.deleteTrack(track: trackCD, moc: moc)                                
                            }
                            
                        }
                        
                      }, secondaryButton: .cancel())
            }
        
    }

    func moveCenterMapToCurLocation() {
        center = clManager.region.center
        appVariables.needChangeMapView = true
    }
    
    func zoomMultiplikator() -> Double {
        
        if span.latitudeDelta < 0.05 {
            return 2
        } else {
            return 5
        }
        
    }

}

//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView()
//    }
//}
