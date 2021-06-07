//
//  JustMapApp.swift
//  JustMap
//
//  Created by test on 24.02.2021.
//

import SwiftUI
import CoreData

@main
struct AntTrackerApp: App {
    
    let persistenceController = PersistenceController.shared
    
    @Environment(\.scenePhase) var scenePhase
    
    @AppStorage("lastUsedLatitude") var lastUsedLatitude: Double = 0
    @AppStorage("lastUsedLongitude") var lastUsedLongitude: Double = 0
    
    let clManager = LocationManager()
    let currentTrack = CurrentTrack.currentTrack
    
    let constants = GlobalAppVars()
    
    init() {
        
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            .environmentObject(clManager)
            .environmentObject(currentTrack)
            .environmentObject(constants)
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            
        }
        .onChange(of: scenePhase) { newScenePhase in
            persistenceController.save()
            
            switch newScenePhase {
                  case .active:
                    return
                  case .inactive:
                    lastUsedLatitude = clManager.location.coordinate.latitude
                    lastUsedLongitude = clManager.location.coordinate.longitude
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
    if globalParameters.printTestData {
        print(Date(), stringToPrint)
    }
}

enum globalParameters {
    static var printTestData = false
    static var pointControlsColor = Color.orange
}

class GlobalAppVars: ObservableObject {
    @Published var needRedrawPointsOnMap = true
    @Published var needChangeMapView = false
}

let pulseAnimation = Animation.easeIn(duration: 1).repeatForever(autoreverses: false)
