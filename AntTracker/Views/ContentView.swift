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
        case settings
    }
    
    @State var activePage: pages = .main
    
    var body: some View {
        
        switch activePage {
        case .trackList:
            TrackListView(activePage: $activePage)
                .transition(.move(edge: .trailing))
        case .settings:
            AppSettings(activePage: $activePage)
                .transition(.move(edge: .trailing))
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