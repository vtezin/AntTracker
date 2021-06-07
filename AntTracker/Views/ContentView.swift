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
        case list
        case settings
    }
    
    @State var activePage: pages = .main
    
    var body: some View {
        
        switch activePage {
        case .list:
            TrackListView(activePage: $activePage)
        case .settings:
            AppSettings(activePage: $activePage)
        default:
            MainView(activePage: $activePage)
        }
        
    }
    
}


//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
