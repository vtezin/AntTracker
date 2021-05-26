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
    let currentTrack = GeoTrack.shared
    @Environment(\.scenePhase) var scenePhase
    
    let clManager = LocationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            .environmentObject(clManager)
            .environmentObject(currentTrack)
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
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
    static var printTestData = true
    static var pointControlsColor = Color.orange
}
