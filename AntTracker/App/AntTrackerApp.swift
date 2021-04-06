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
    
    @StateObject var clManager = LocationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            .environmentObject(clManager)
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
    }
}
