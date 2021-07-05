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

func shareTextAsKMLFile(text: String, filename: String) {

    // Convert the String into Data
    let textData = text.data(using: .utf8)

    // Write the text into a filepath and return the filepath in NSURL
    // Specify the file type you want the file be by changing the end of the filename (.txt, .json, .pdf...)
    let textURL = textData?.dataToFile(fileName: filename + ".kml")

    // Create the Array which includes the files you want to share
    var filesToShare = [Any]()

    // Add the path of the text file to the Array
    filesToShare.append(textURL!)

    // Make the activityViewContoller which shows the share-view

    // Show the share-view
    let av = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
            UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
    
    
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

let pulseAnimation = Animation.easeIn(duration: 1).repeatForever(autoreverses: false)
