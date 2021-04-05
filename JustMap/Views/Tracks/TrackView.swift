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
    
    let track: Track
    
    @State var title = ""
    @State var info = ""
    @State var region = ""
    @State var showOnMap = false
    @State var color: Color = .orange
    
    @State private var mapType: MKMapType = .hybrid
    
    enum Tab {
        case map
        case properties
    }
    
    @State private var currentTab: Tab = .map
    
    var body: some View {
        
        TabView(selection: $currentTab) {
            
            ZStack{
                
                TrackMapView(track: track, mapType: $mapType)
                
                
                VStack {
                    
                    TrackInfo(geoTrack: track.convertToGeoTrack())
                        .modifier(MapControl())
                    
                    Spacer()
                    
                }
                
            }
            .tabItem {
                Label("Map", systemImage: "map")
            }
            .tag(Tab.map)
            
            Form{
                
                Section(header: Text("Title")) {
                    TextField("", text: $title)
                    HStack{
                        ColorSelectorView(selectedColor: $color)
                    }
                }
                
                Section(header: Text("Description")) {
                    TextField("", text: $info)
                }
                
                
                Section(header: Text("Region")) {
                    TextField("", text: $region)
                }
                
                Section(header: Text("Info")) {
                    VStack(alignment: .leading){
                        Text("start:" + " " + track.startDate.dateString())
                        Text("finish:" + " "  + track.finishDate.dateString())
                        Text("distance:" + " "  + String(track.totalDistance))
                        Text("points:" + " "  + String(track.trackPointsArray.count))
                        
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }
                
//                Section(header: Text("Points")) {
//
//                    List{
//
//                        ForEach(track.geoPoints(), id: \.self) { point in
//                            Text(point.speed)
//                        }
//                    }
//
//                }
                
                
            }
            .tabItem {
                Label("Properties", systemImage: "list.bullet")
            }
            .tag(Tab.properties)
            

            
        }
        
        
        .onAppear{
            
            title = track.title
            info = track.info
            region = track.region
            showOnMap = track.showOnMap
            color = Color.getColorFromName(colorName: track.color)
            
        }
        .navigationBarTitle(Text(track.title), displayMode: .inline)
        
        .navigationBarItems(
            trailing: Button(action: {
                save()
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Save")
            })
        
    }
    
    func save() {
        
        track.title = title
        track.info = info
        track.region = region
        track.showOnMap = showOnMap
        track.color = color.description
        
        try? self.moc.save()
        
    }
    
}

//struct TrackView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackView(track: Track())
//    }
//}
