//
//  TrackDetailsView.swift
//  AntTracker
//
//  Created by test on 27.05.2021.
//

import SwiftUI
import MapKit

struct TrackDetailsView: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("lastUsedMapType") var lastUsedMapType: String = "hybrid"
    
    @State private var showQuestionBeforeDelete = false
    
    let track: Track
    @State private var statistics: newTrackStatistics?
    
    //track props
    @State private var title = ""
    @State private var info = ""
    @State private var color: Color = .orange
    @State private var trackGroup: TrackGroup?
    
    @State private var initDone = false
    
    //working whith map
    @State private var mapType: MKMapType = .hybrid
    @State private var mapSettingsChanged = false
    
    init(track: Track) {
        self.track = track
    }
    
    var body: some View {
        
        TabView {
            mapView
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .onAppear {
                    
                    mapType = lastUsedMapType == "hybrid" ? .hybrid : .standard
                    
                    if !initDone {
                        
                        print("init on Appear")
                        
                        title = track.title
                        info = track.info
                        color = Color.getColorFromName(colorName: track.color)
                        trackGroup = track.trackGroup
                        
                        statistics = track.newGetStatictic()
                        
                        initDone = true
                        
                    }
                }
            
            infoView
                .tabItem {
                    Label("Info", systemImage: "info.circle")
                }
        }
        
        .alert(isPresented:$showQuestionBeforeDelete) {
            Alert(title: Text("Delete this track?"), message: Text("There is no undo"), primaryButton: .destructive(Text("Delete")) {
                
                delete()
                presentationMode.wrappedValue.dismiss()
                
            }, secondaryButton: .cancel())
        }
        
        .navigationBarTitle(Text(track.title), displayMode: .inline)
        .navigationBarItems(trailing:
                                Button(action: {
                                    save()
                                    mapSettingsChanged = color.description != track.color
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    Text("Done")
                                })
        
        
    }
    
    var mapView: some View {
        
        VStack{
            
            TrackInfo(track: track, statistics: statistics)
                .modifier(MapControl())
                .clipShape(RoundedRectangle(cornerRadius: 5))
            
            ZStack{
                
                //hint for redraw map when settings changed
                if mapSettingsChanged {
                    TrackMapView(track: track, mapType: $mapType)
                } else {
                    TrackMapView(track: track, mapType: $mapType)
                }
                
                VStack {
                    
                    Spacer()
                    
                    HStack{
                        
                        Button(action: {
                            mapType = mapType == .standard ? .hybrid : .standard
                        }) {
                            Image(systemName: mapType == .standard ? "globe" : "map")
                                .modifier(MapButton())
                        }
                        
                        Spacer()
                        
                    }
                    .padding()
                    
                }
                
            }
            
        }
        
    }
    
    var infoView: some View {
        
        Form{
            
            Section(header: Text("Title")) {
                TextField("Title", text: $title)
                    .modifier(ClearButton(text: $title))
                    .foregroundColor(color)
                ColorSelectorView(selectedColor: $color)
            }
            
            Section(header: Text("Description")) {
                
                ZStack {
                    TextEditor(text: $info)
                    Text(info).opacity(0).padding(.all, 8)
                }
                
            }
            
            Section(header: Text("Track group")) {
                NavigationLink(destination: TrackGroupSelectionView(selectedGroup: $trackGroup)) {
                        Text(trackGroup?.title ?? "")
                }
            }
            
                
            Button(action: {
                showQuestionBeforeDelete = true
            }) {
                Text("Delete track")
                    .foregroundColor(.red)
            }
            
            
        }
        
    }
    
    func delete() {
        Track.deleteTrack(track: track, moc: moc)
    }
    
    func save() {
        
        track.title = title
        track.info = info
        track.color = color.description
        track.trackGroup = trackGroup
        
        try? moc.save()
        
    }
    
}

//struct TrackDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackDetailsView()
//    }
//}
