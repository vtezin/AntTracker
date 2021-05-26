//
//  TrackView.swift
//  JustMap
//
//  Created by test on 25.03.2021.
//

import SwiftUI
import MapKit

struct TrackView: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("lastUsedMapType") var lastUsedMapType: String = "hybrid"
    
    @State private var showQuestionBeforDelete = false
    
    let track: Track
    
    @State private var mapType: MKMapType = .hybrid
    @State private var showSettings = false
    @State private var mapSettingsChanged = false
    
    enum Tab {
        case map
        case properties
    }
    
    @State private var currentTab: Tab = .map
    
    var body: some View {
        
        ZStack{
            
            //hint for redraw map when settings changed
            if mapSettingsChanged {
                TrackMapView(track: track, mapType: $mapType)
            } else {
                TrackMapView(track: track, mapType: $mapType)
            }
            
            VStack {
                
                TrackInfo(geoTrack: track.convertToGeoTrack())
                    .modifier(MapControl())
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .padding(5)
                
                Spacer()
                
                HStack{
                    
                    Button(action: {
                        mapType = mapType == .standard ? .hybrid : .standard
                    }) {
                        Image(systemName: mapType == .standard ? "globe" : "map")
                            .modifier(MapButton())
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape")
                            .modifier(MapButton())
                    }
                    
                }
                .padding()
                
            }
            
        }
        
        .onAppear{
            mapType = lastUsedMapType == "hybrid" ? .hybrid : .standard
        }
        
        .sheet(isPresented: $showSettings) {
            TrackPropertiesView(track: track, currentTrack: nil, mapSettingsChanged: $mapSettingsChanged)
                .environment(\.managedObjectContext, moc)
        }
        .alert(isPresented:$showQuestionBeforDelete) {
            Alert(title: Text("Delete this track?"), message: Text("There is no undo"), primaryButton: .destructive(Text("Delete")) {
                
                delete()
                self.presentationMode.wrappedValue.dismiss()
                
            }, secondaryButton: .cancel())
        }
        
        .navigationBarTitle(Text(track.title), displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            
           showQuestionBeforDelete = true
            
        }) {
            HStack{
                Image(systemName: "trash")
            }
        })
        
    }
    
    
    func delete() {
        
        Track.deleteTrack(track: track, moc: moc)
        
    }
    
    
}

//struct TrackView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackView(track: Track())
//    }
//}
