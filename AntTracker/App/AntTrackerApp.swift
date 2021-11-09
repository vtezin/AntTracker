//
//  JustMapApp.swift
//  JustMap
//
//  Created by test on 24.02.2021.
//

import SwiftUI
import CoreData
import MapKit

@main
struct AntTrackerApp: App {
    
    let persistenceController = PersistenceController.shared
    
    @Environment(\.scenePhase) var scenePhase
    
    @AppStorage("lastUsedCLLatitude") var lastUsedCLLatitude: Double = 0
    @AppStorage("lastUsedCLLongitude") var lastUsedCLLongitude: Double = 0
    @AppStorage("lastUsedCLAltitude") var lastUsedCLAltitude: Int = 0
    
    @AppStorage("currentTrackCoreDataUIIDString") var currentTrackCoreDataUIIDString = ""
    @AppStorage("trackRecordingState") var trackRecordingState = "none"
    
    let clManager = LocationManager()
    let currentTrack = CurrentTrack.currentTrack
    
    @StateObject var appVariables = AppVariables()
    
    init() {
        
        if currentTrack.trackCoreData == nil && !currentTrackCoreDataUIIDString.isEmpty {
            restoreTrackRecording(currentTrackCoreDataUIIDString: currentTrackCoreDataUIIDString)
        }
        
    }
    
    func restoreTrackRecording(currentTrackCoreDataUIIDString: String) {
        
        let trackCDUUID = UUID(uuidString: currentTrackCoreDataUIIDString)
        
//        print("restore track recording " + trackCDUUID!.uuidString)
//        print(trackRecordingState)
        
        let moc = persistenceController.container.viewContext
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "Track", in: moc)
        
        let request = NSFetchRequest<NSFetchRequestResult>()
        
        request.entity = entityDescription
        request.predicate = NSPredicate(format: "id == %@", trackCDUUID! as CVarArg)
        
        do {
            
            let tracks = try moc.fetch(request)
            
            guard tracks.count == 1 else {
                return
            }
            
            let trackCoreData = tracks.first! as! Track
            
            currentTrack.trackCoreData = trackCoreData
            currentTrack.fillByTrackCoreData(trackCD: trackCoreData)
            
            switch trackRecordingState {
            case "recording":
                clManager.trackRecordingState = .recording
            case "paused":
                clManager.trackRecordingState = .paused
            default:
                clManager.trackRecordingState = .none
            }
            
            //print("track record restored")
            
        } catch {
            //just failed restoring
        }
        
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(clManager)
                .environmentObject(currentTrack)
                .environmentObject(appVariables)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(colorSheme(darkMode: appVariables.darkMode))
        }
        .onChange(of: scenePhase) { newScenePhase in
            persistenceController.save()
            
            switch newScenePhase {
                  case .active:
                    return
                  case .inactive:
                    lastUsedCLLatitude = clManager.location.coordinate.latitude
                    lastUsedCLLongitude = clManager.location.coordinate.longitude
                    lastUsedCLAltitude = Int(clManager.location.altitude)
                  case .background:
                    return
                    //print("App is in background")
                  @unknown default:
                    return
                    //print("Oh - interesting: I received an unexpected new value.")
                  }
            
        }

    }
}

func currentTrackColorName() -> String {
    let defaults = UserDefaults.standard
    return defaults.string(forKey: "currentTrackColor") ?? "orange"
}

func printTest(_ stringToPrint: String) {
    if AppConstants.printTestData {
        print(Date(), stringToPrint)
    }
}

enum AppConstants {
    
    static var printTestData = false
    static let defaultColor = Color.orange
    
    //span
    static let minSpan: Double = 0.0008
    static let maxSpan: Double = 108
    static let curLocationSpan = minSpan * 3
    
}

class AppVariables: ObservableObject {
    
    @Published var needRedrawPointsOnMap = true
    @Published var needChangeMapView = false
    @Published var selectedPoint: Point?
    @Published var centerOfMap = CLLocationCoordinate2D()
    @Published var mapSettingsForAppear: (latitude: CLLocationDegrees,
                                          longitude: CLLocationDegrees,
                                          span: Double?)?
    
    @Published var darkMode: Bool? = nil
    
    var lastUsedPointGroup: PointGroup?
    
}

func colorSheme(darkMode: Bool?) -> ColorScheme? {
    
    if let darkMode = darkMode {
        return darkMode ? .dark : .light
    } else {
        return nil
    }
    
}

func colorForMapText(mapType: MKMapType, colorScheme: ColorScheme) -> Color {
    
    if mapType == .hybrid {
        return colorScheme == .dark ? .primary : .systemBackground
    } else {
        return .primary
    }
    
}

func actionSheetForDelete(title: LocalizedStringKey, deleteAction: @escaping ()->Void, cancelAction: @escaping ()->Void) -> ActionSheet {
    ActionSheet(
        title: Text(title),
        message: Text("There is no undo"),
        buttons: [
            .destructive(Text("Delete")) {
                deleteAction()
            },
            
            .cancel(Text("Cancel")) {
                cancelAction()
            }
        ]
    )
}

func makeVibration() {

    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.success)
    
}

let pulseAnimation = Animation.easeIn(duration: 1).repeatForever(autoreverses: false)
let appVars = AppVariables()
let geocoder = CLGeocoder()
