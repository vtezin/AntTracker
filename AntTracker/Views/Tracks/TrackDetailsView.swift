//
//  TrackDetailsView.swift
//  AntTracker
//
//  Created by test on 27.05.2021.
//

import SwiftUI
import MapKit

struct TrackDetailsView: View {
    
    @Binding var activePage: ContentView.pages
    @Binding var trackListRefreshID: UUID
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("lastUsedMapType") var lastUsedMapType: String = "hybrid"
    
    @State private var showQuestionBeforeDelete = false
    @State private var showInfo = false
    
    let track: Track
    @State private var statistics: TrackStatistic?
    
    //track props
    @State private var title: String
    @State private var info: String
    @State private var color: Color
    @State private var trackGroup: TrackGroup?
    
    //working whith map
    @State private var mapType: MKMapType = .hybrid
    @State private var showMap = false
    
    init(track: Track, activePage: Binding<ContentView.pages>, trackListRefreshID: Binding<UUID>) {
        
        self.track = track
        
        _title = State(initialValue: track.title)
        _info = State(initialValue: track.info)
        _color = State(initialValue: Color.getColorFromName(colorName: track.color))
        _trackGroup = State(initialValue: track.trackGroup)
        _activePage = activePage
        _trackListRefreshID = trackListRefreshID
        
    }
    
    var body: some View {
        
        VStack{
            
//            ZStack{
//                mapView
//                if showInfo {
//                    infoView
//                }
//            }
        
            if showInfo {
                infoView
            } else {
                mapView
            }
            
            Spacer()
            
            HStack{
                
                Button(action: {
                    showInfo = false
                }) {
                    VStack{
                        Image(systemName: "map")
                            .modifier(ControlButton())
                        Text("Map").buttonText()
                    }
                }
                
                Spacer()
                
                Button(action: {
                    showInfo = true
                }) {
                    VStack{
                        Image(systemName: "info.circle")
                            .modifier(ControlButton())
                        Text("Info").buttonText()
                    }
                }
                
                Spacer()
                
                Menu{
                    
                    Button(action: {
                        showQuestionBeforeDelete = true
                    }) {
                        Label("Delete track", systemImage: "trash")
                    }
                    
                    Button(action: {
                        CurrentTrack.currentTrack.fillByTrackCoreData(trackCD: track)
                        activePage = .main
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Label("Resume track", systemImage: "")
                        .labelStyle(TitleOnlyLabelStyle())
                    }
                    
                    
                    Button(action: {
                        mapType = mapType == .standard ? .hybrid : .standard
                        lastUsedMapType = mapType == .standard ? "standart" : "hybrid"
                    }) {
                        Label(mapType == .standard ? "Switch to satellite" : "Switch to standard map",
                              systemImage: "")
                            .labelStyle(TitleOnlyLabelStyle())
                    }
                    
                    
                } label: {
                    VStack{
                        Image(systemName: "ellipsis.circle")
                            .modifier(ControlButton())
                        Text("More").buttonText()
                    }
                }
                
            }
            .padding(.init(top: 3, leading: 15, bottom: 3, trailing: 15))
            
        }
        
        .onAppear {
            
            mapType = lastUsedMapType == "hybrid" ? .hybrid : .standard
            
            printTest("init on Appear")
            
            if statistics == nil {
                statistics = track.getStatistic(moc: moc)
                showMap = true
            } else {
                showMap = true
            }
            
        }
        
        .alert(isPresented:$showQuestionBeforeDelete) {
            Alert(title: Text("Delete this track?"), message: Text("There is no undo"), primaryButton: .destructive(Text("Delete")) {
                
                delete()
                presentationMode.wrappedValue.dismiss()
                
            }, secondaryButton: .cancel())
        }
        
        .navigationBarTitle(Text(title), displayMode: .inline)
        .navigationBarItems(trailing:
                                Button(action: {
                                    save()
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    Text("Done")
                                })
        
        
    }
    
    var mapView: some View {
        
        VStack{
            
            ZStack{
                
                if showMap {
                    TrackMapView(statistics: statistics!,
                                 trackTitle: track.title,
                                 trackColor: track.color,
                                 mapType: $mapType)
                    
                    VStack{
                        
                        HStack{
                            Text(localeDistanceString(distanceMeters: track.totalDistanceMeters))
                                .font(.title3)
                                .fontWeight(.light)
                            
                            Spacer()
                            
                            Text(track.durationString)
                                .fontWeight(.light)
                            
                        }
                        .foregroundColor(mapType == MKMapType.hybrid ? .systemBackground : .primary)
                        
                        Spacer()
                    }
                    .padding()
                    
                }
                
            }
                
            
        }
        
    }
    
    var infoView: some View {
        
        Form{
            
            TextField("Title", text: $title)
                .modifier(ClearButton(text: $title))
                .foregroundColor(color)
            ColorSelectorView(selectedColor: $color)
            
            //Section(header: Text("Track group")) {
                NavigationLink(destination: TrackGroupSelectionView(selectedGroup: $trackGroup)) {
                    TrackGroupRawView(trackGroup: trackGroup)
                }
            //}
            
            Section(header: Text("Description")) {
                
                ZStack {
                    TextEditor(text: $info)
                    Text(info).opacity(0).padding(.all, 8)
                }
                
            }
            
                
            HStack{
                
                VStack {
                    HStack{
                        Image(systemName: "hare")
                    }
                    .padding(.bottom, 5)
                    
                    HStack {
                        Text("avg")
                            .fontWeight(.light)
                        Text(" \(statistics?.averageSpeed.localeSpeedString ?? "")")
                            .fontWeight(.light)
                    }
                    
                    HStack {
                        Text("max")
                            .fontWeight(.light)
                        Text(" \(statistics?.maxSpeed.localeSpeedString ?? "")")
                            .fontWeight(.light)
                    }
                    
                }
                
                Spacer()
                
                VStack {
                    HStack{
                        //Image(systemName: "arrow.up")
                        Text("altitude")
                    }
                    .padding(.bottom, 5)
                    
                    VStack {
                        HStack{
                            Text("\(statistics?.minAltitude ?? 0)")
                                .fontWeight(.light)
                            Image(systemName: "arrow.up.right")
                            Text("\(statistics?.maxAltitude ?? 0)")
                                .fontWeight(.light)
                        }
                        Text("(\((statistics?.maxAltitude ?? 0) - (statistics?.minAltitude ?? 0)))" + "m")
                            .fontWeight(.light)
                    }
                    
                }
                
            }
            
            
            
        }
        
    }
    
    func resumeTrackPressed() {
        
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
        
        trackListRefreshID = UUID()
        
    }
    
}

//struct TrackDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackDetailsView()
//    }
//}
