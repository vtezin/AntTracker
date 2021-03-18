//
//  JustMapApp.swift
//  JustMap
//
//  Created by test on 24.02.2021.
//

import SwiftUI

@main
struct JustMapApp: App {
    
    @StateObject var clManager = LocationManager()
    //@StateObject var currentTrack = Track()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            .environmentObject(clManager)
        }
    }
}
