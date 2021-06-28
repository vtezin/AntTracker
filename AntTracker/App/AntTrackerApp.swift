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
                    lastUsedCLLatitude = clManager.location.coordinate.latitude
                    lastUsedCLLongitude = clManager.location.coordinate.longitude
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
    @Published var editingPoint: Point? = nil
    @Published var centerOfMap = CLLocationCoordinate2D()
}

func colorForMapText(mapType: MKMapType, colorScheme: ColorScheme) -> Color {
    if mapType == .hybrid {
        return colorScheme == .dark ? .primary : .systemBackground
    } else {
        return .primary
    }
}

let pulseAnimation = Animation.easeIn(duration: 1).repeatForever(autoreverses: false)
