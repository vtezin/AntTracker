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
    @State var curLocationIsOnVisibleMapRegion = false
    @AppStorage("lastUsedMapType") var lastUsedMapType: String = "hybrid"
    
    @State var center = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    @State var span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    
    @State var needChangeMapView = false
    @State var followCLbyMap = false
    
    @AppStorage("lastUsedCLLatitude") var lastUsedCLLatitude: Double = 0
    @AppStorage("lastUsedCLLongitude") var lastUsedCLLongitude: Double = 0
    @AppStorage("lastMapDisapearingDate") var lastMapDisapearingDate: Date = Date()
    
    @AppStorage("mainViewShowCurrentAlt") var mainViewShowCurrentAltitude: Bool = false
    @AppStorage("mainViewShowCurrentSpeed") var mainViewShowCurrentSpeed: Bool = true
    
    @SceneStorage("lastUsedMapCenterLatitude") var lastUsedMapCenterLatitude: Double = 0
    @SceneStorage("lastUsedMapCenterLongitude") var lastUsedMapCenterLongitude: Double = 0
    @SceneStorage("lastUsedMapSpan") var lastUsedMapSpan: Double = 0.01
    
    //work whith points
    @AppStorage("showPointsOnTheMap") var showPointsOnTheMap = true
    
    //action sheets support
    @State var showActionSheet = false
    enum ActionSheetModes {
        case deleteSelectedPoint, currentTrackActions
    }
    @State var actionSheetMode: ActionSheetModes = .currentTrackActions
    
    //import point
    @AppStorage("lastUsedPointColor") var lastUsedPointColor: String = "orange"
    @State var coordinatesForImportPoint = ""
    @State var showGoToCoordinates = false
    @State var showInvalidFormatGoToCoordinates = false
    
    //Core Data
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Point.entity(), sortDescriptors: []) var points: FetchedResults<Point>
    
    //current location & track
    @EnvironmentObject var clManager: LocationManager
    @EnvironmentObject var currentTrack: CurrentTrack
    
    @AppStorage("currentTrackColor") var currentTrackColor: String = "orange"
    //constants
    @EnvironmentObject var appVariables: AppVariables
    
    //controls visibility
    @State var showControls = true
    @State var showPointsManagment = false {
        didSet{
            selectedPositionAddress = "address definition..."
        }
    }
    
    //track
    @State var showQuestionBeforeResetTrack = false
    
    //animations
    @State var animationsCurLocationButtonRotatesCount: Double = 0
    
    //other
    @AppStorage("disableAutolockScreen") var disableAutolockScreen: Bool = false
    @State var dateOfSavingCurrentTrack = Date()
    
    //select position support
    @State var selectedPositionDistanceFromCL = ""
    @State var selectedPositionAddress = ""
    
    //ant animation support
    @State var animatingProperties = AntAnimatingProperties()
    @State var animateAnt = false
    
    //quick add point support
    @State var lastQuickAddedPoint: Point?
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
                
                ZStack{
                    
                    MapView(mapType: $mapType, center: $center, span: $span, curLocationIsOnVisibleMapRegion: $curLocationIsOnVisibleMapRegion, points: points, showPointsOnTheMap: $showPointsOnTheMap, followCLbyMap: $followCLbyMap, showPointsManagment: $showPointsManagment, activePage: $activePage)
                        .onTapGesture {
                            withAnimation{
                                if !showPointsManagment {
                                    showControls.toggle()
                                } else {
                                    showPointsManagment = false
                                }
                                appVariables.selectedPoint = nil
                            }
                        }
                        .onReceive(timer) { _ in
                            if followCLbyMap{
                                moveCenterMapToCurLocation()
                            }
                            if showPointsManagment {
                                
                                selectedPositionDistanceFromCL = localeDistanceString(distanceMeters: CLLocation(latitude: center.latitude, longitude: center.longitude).distance(from: clManager.location))
                                
                                getDescriptionByCoordinates(latitude: center.latitude,
                                                            longitude: center.longitude,
                                                            handler: fillSelectedPositionAdress)
                                
                            }
                        }
                    .edgesIgnoringSafeArea(.all)
                    
                    //map controls layer
                        
                    VStack{
                        
                        HStack{
                            
                            VStack{
                                Spacer()
                                Spacer()
                                Spacer()
                                buttonMapType
                                    .padding(.leading)
                                Spacer()
                            }
                            
                            Spacer()
                            
                            VStack{
                                Spacer()
                                Spacer()
                                buttonZoomIn
                                buttonZoomOut
                                    .padding(.top)
                                Spacer()
                                buttonCurLocation
                                Spacer()
                                Spacer()
                            }
                            .padding()
                            
                        }
                                
                        
                    }
                    
                    if showPointsManagment {
                        VStack{
                            Image(systemName: "plus")
                                .imageScale(.large)
                                .font(Font.title.weight(.light))
                        }
                        .foregroundColor(colorForMapText(mapType: mapType, colorScheme: colorScheme))
                    }
                    
                    VStack{
                        
                        if showControls
                            && (clManager.trackRecordingState != .none)
                            && appVariables.selectedPoint == nil {
                            CurrentTrackInfo()
                                .padding(.leading)
                                .padding(.trailing)
                                .transition(.move(edge: .top))
                        }
                        
                        HStack{
                            
                            if mainViewShowCurrentAltitude {
                                altInfo()
                                    .padding()
                            }
                            
                            Spacer()
                            
                            if mainViewShowCurrentSpeed {
                                speedInfo()
                                    .padding()
                            }
                            
                        }
                        
                        Spacer()
                        
                        
                        if appVariables.selectedPoint != nil {
                            //selected point info
                            selectetPointInfo
                            
                        } else {
                            
                            gpsAccuracyInfo()
                                .padding()
                            
                            //controls
                            
                            if showControls || showPointsManagment {
                                
                                HStack{
                                    
                                    if showPointsManagment {
                                        pointControlsPane
                                    }
                                    else {
                                        mainControlsPane
                                    }
                                    
                                }
                                
                            }
                        }
                            
                        }
                    
                }
                

                
            
            .onAppear{
                
                UIApplication.shared.isIdleTimerDisabled = disableAutolockScreen
                
                setMapPositionOnAppear()
                
                mapType = lastUsedMapType == "hybrid" ? .hybrid : .standard
                appVariables.needChangeMapView = true
                appVariables.needRedrawPointsOnMap = true
                
            }
            
            .onDisappear{
                saveSceneStorages()
            }
            
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                //print("willEnterForegroundNotification")
                setMapPositionOnAppear()
            }
            
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                saveSceneStorages()
            }

            
            .alert(isPresented: $showQuestionBeforeResetTrack) {
                Alert(title: Text("Reset current track?"),
                      primaryButton: .destructive(Text("Reset")) {
                        
                        moveCenterMapToCurLocation()
                        
                        withAnimation{
                            resetTrack()                            
                        }
                        
                      }, secondaryButton: .cancel())
            }
        
            .actionSheet(isPresented: $showActionSheet) {
                
                if actionSheetMode == .deleteSelectedPoint {
                    return actionSheetForDelete(title: "Delete this point?") {
                        deleteSelectedPoint()
                    } cancelAction: {
                        showActionSheet = false
                    }
                } else {
                    
                    return ActionSheet(
                        title: Text("Track recording"),
                        message: Text(""),
                        buttons: currentTrackActions()
                    )
                }
                
            }
        
    }

    func fillSelectedPositionAdress(adressString: String) {
        
        withAnimation {
            selectedPositionAddress = adressString
        }
        
    }
    
    func setMapPositionOnAppear() {
        
        if let mapSettingsForAppear = appVariables.mapSettingsForAppear {
            
            center = CLLocationCoordinate2D(latitude: mapSettingsForAppear.latitude,
                                            longitude: mapSettingsForAppear.longitude)
            
            if let span = mapSettingsForAppear.span {
                setMapSpan(delta: span)
            }
            
            appVariables.mapSettingsForAppear = nil
            return
        }
        
        let minutesFromLastShoutDown = Date().seconds(from: lastMapDisapearingDate) / 60
        
        //print("last shdown \(lastShutdownDate) - \(Date().seconds(from: lastShutdownDate)) seconds")
        
        if minutesFromLastShoutDown > 10 {
            
            //go to current position
            tryToSetMapPositionByCurrentLocation()
            return
            
        }
        
        if lastUsedMapCenterLatitude != 0  {
            
            //restore saved state
            //print("restore saved state (lastUsedMapCenterLatitude : \(lastUsedMapCenterLatitude)")
            
            center = CLLocationCoordinate2D(latitude: lastUsedMapCenterLatitude,
                                            longitude: lastUsedMapCenterLongitude)
            
            span = MKCoordinateSpan(latitudeDelta: lastUsedMapSpan,
                                    longitudeDelta: lastUsedMapSpan)
            return
            
        }
        
        tryToSetMapPositionBySavedCurentLocation()
        
    }
    
    func tryToSetMapPositionByCurrentLocation() {
        
        let clReceived = clManager.region.center.latitude != 0
            || clManager.region.center.longitude != 0

        if clReceived {
            if clManager.location.horizontalAccuracy < 50 {
                setMapSpan(delta: AppConstants.curLocationSpan)
            }
            moveCenterMapToCurLocation()
        } else {
            tryToSetMapPositionBySavedCurentLocation()
        }
        
    }
    
    func tryToSetMapPositionBySavedCurentLocation() {
        
        let lastUsedCLReceived = lastUsedCLLongitude != 0
            && lastUsedCLLatitude != 0
        
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
    
    func saveSceneStorages() {
        lastUsedMapCenterLatitude = center.latitude
        lastUsedMapCenterLongitude = center.longitude
        lastUsedMapSpan = span.latitudeDelta
        lastMapDisapearingDate = Date()
    }
    
    func moveCenterMapToCurLocation() {
        center = clManager.region.center
        appVariables.needChangeMapView = true
        followCLbyMap = true
    }

}

//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView()
//    }
//}
