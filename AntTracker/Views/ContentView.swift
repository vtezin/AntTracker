//
//  ContentView.swift
//  JustMap
//
//  Created by test on 24.02.2021.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    //pages support
    enum pages: Identifiable {
        var id: Int {hashValue}
        case main
        case trackList
        case pointList
        case settings
        case editPoint
        case completeTrack
    }
    
    @State var activePage: pages = .main
    @State private var pointListRefreshID: UUID? = nil //for force refreshing
    @EnvironmentObject var appVariables: GlobalAppVars
    
    var body: some View {
        
        switch activePage {
        case .trackList:
            TrackListView(activePage: $activePage)
                .transition(.move(edge: .trailing))
        case .pointList:
            PointListView(activePage: $activePage)
                .transition(.move(edge: .trailing))
        case .settings:
            AppSettings(activePage: $activePage)
                .transition(.move(edge: .trailing))
        case .editPoint:
            PointDetailView(point: appVariables.editingPoint,
                      centerOfMap: appVariables.centerOfMap,
                      activePage: $activePage,
                      pointListRefreshID: $pointListRefreshID)
                .transition(.move(edge: .bottom))
        case .completeTrack:
            CompleteRecordTrack(activePage: $activePage)
                .transition(.move(edge: .bottom))        
        default:
            MainView(activePage: $activePage)
            //.transition(.move(edge: .leading))
        }
        
    }
    
}


//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
