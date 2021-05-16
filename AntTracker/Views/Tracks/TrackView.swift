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
    
    @State var title = ""
    @State var info = ""
    @State var region = ""
    @State var showOnMap = false
    @State var color: Color = .orange
    
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
            
            title = track.title
            info = track.info
            region = track.region
            showOnMap = track.showOnMap
            color = Color.getColorFromName(colorName: track.color)
            
            mapType = lastUsedMapType == "hybrid" ? .hybrid : .standard
            
        }
        
        .sheet(isPresented: $showSettings) {
            trackSettings
        }
        .alert(isPresented:$showQuestionBeforDelete) {
            Alert(title: Text("Delete this track?"), message: Text("There is no undo"), primaryButton: .destructive(Text("Delete")) {
                
                delete()
                self.presentationMode.wrappedValue.dismiss()
                
            }, secondaryButton: .cancel())
        }
        
        .navigationBarTitle(Text(title), displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            
           showQuestionBeforDelete = true
            
        }) {
            HStack{
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        })
        
    }
    
    func save() {
        
        track.title = title
        track.info = info
        track.region = region
        track.showOnMap = showOnMap
        track.color = color.description
        
        try? moc.save()
        
    }
    
    func delete() {
        
        Track.deleteTrack(track: track, moc: moc)
        
    }
    
    
    var trackSettings: some View {
        
        NavigationView {
            
            Form{
                
                Section(header: Text("Title")) {
                    TextField("", text: $title).modifier(ClearButton(text: $title))
                }
                
                Section(header: Text("Color")) {
                    ColorSelectorView(selectedColor: $color)
                }
                
                Section(header: Text("Description")) {
                    
                    ZStack {
                        TextEditor(text: $info)
                        Text(info).opacity(0).padding(.all, 8)
                    }
                    
                }
                
            }
            .navigationBarTitle(Text("Settings"), displayMode: .inline)
            .navigationBarItems(
                trailing: Button(action: {
                    save()
                    showSettings = false
                    mapSettingsChanged.toggle()
                }) {
                    Text("Save")
                })
            
        }
        
    }
    
}

//struct TrackView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackView(track: Track())
//    }
//}
