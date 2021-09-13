//
//  TrackDetailsView.swift
//  AntTracker
//
//  Created by test on 27.05.2021.
//

import SwiftUI
import MapKit

struct TrackDetailView: View {
    
    @Binding var activePage: ContentView.pages
    @Binding var trackListRefreshID: UUID
    
    @State var currentPage: pages = .map
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("lastUsedMapType") var lastUsedMapType: String = "hybrid"
    
    @State private var showQuestionBeforeDelete = false
    
    let track: Track
    @State private var statistics: TrackStatistic?
    @State private var showColorSelector = false
    
    //track props
    @State private var title: String
    @State private var info: String
    @State private var locationString: String
    @State private var color: Color
    
    //selecting group
    @State private var trackGroup: TrackGroup?
    @State private var trackGroupOnAppear: TrackGroup?
    @State private var showGroupSelection = false
    
    //working whith map
    @State private var mapType: MKMapType = .hybrid
    @State private var showMap = false
    
    @State private var showControls = true
    
    init(track: Track, activePage: Binding<ContentView.pages>, trackListRefreshID: Binding<UUID>) {
        
        self.track = track
        
        _title = State(initialValue: track.wrappedTitle)
        _info = State(initialValue: track.wrappedInfo)
        _locationString = State(initialValue: track.wrappedLocationString)
        _color = State(initialValue: Color.getColorFromName(colorName: track.wrappedColor))
        _trackGroup = State(initialValue: track.trackGroup)
        _activePage = activePage
        _trackListRefreshID = trackListRefreshID
        
        _trackGroupOnAppear = _trackGroup
        
    }
    
    enum pages: Identifiable {
        var id: Int {hashValue}
        case map
        case info
    }
    
    var body: some View {
        
        VStack{
        
            switch currentPage {
            case .map:
                mapView
                    .onTapGesture {
                        withAnimation {
                            showControls.toggle()
                        }
                    }
            case .info:
                infoView
            }
            
            if showControls {
                
                Spacer()
                
                HStack{
                    
                    Button(action: {
                        kmlAPI.shareTextAsKMLFile(text: track.getTextForKMLFile(),
                                                  filename: track.wrappedTitle)
                    }) {
                        VStack{
                            Image(systemName: "square.and.arrow.up")
                                .modifier(ControlButton())
                            Text("Share").buttonText()
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        currentPage = currentPage == .map ? .info : .map
                    }) {
                        VStack{
                            Image(systemName: currentPage == .map ? "info.circle" : "map")
                                .modifier(ControlButton())
                            Text(currentPage == .map ? "Info" : "Map").buttonText()
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
        
        .sheet(isPresented: $showGroupSelection) {
            TrackGroupSelectionView(selectedGroup: $trackGroup)
                .environment(\.managedObjectContext, moc)
        }
        
        .actionSheet(isPresented: $showQuestionBeforeDelete) {
            
            actionSheetForDelete(title: "Delete this track?") {
                delete()
                presentationMode.wrappedValue.dismiss()
            } cancelAction: {
                showQuestionBeforeDelete = false
            }

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
                                 trackTitle: track.wrappedTitle,
                                 trackColor: track.wrappedColor,
                                 mapType: $mapType)
                    
                    VStack{
                        
                        if showControls {
                            
                            HStack{
                                Text(localeDistanceString(distanceMeters: track.totalDistanceMeters))
                                    .font(.title3)
                                    .fontWeight(.light)
                                
                                Spacer()
                                
                                Text(track.durationString)
                                    .fontWeight(.light)
                                
                            }
                            .foregroundColor(colorForMapText(mapType: mapType, colorScheme: colorScheme))
                            
                        }
                        
                        
                        Spacer()
                        
                        HStack{
                            
                            Image(mapType == .standard ? "satelite": "map")
                                .frame(width: 50, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                                .clipShape(Circle())
                                .clipped()
                                .opacity(0.8)
                                .onTapGesture() {
                                    mapType = mapType == .standard ? .hybrid : .standard
                                    lastUsedMapType = mapType == .standard ? "standart" : "hybrid"
                                }
                                .padding()
                            
                            Spacer()
                            
                        }
                        
                        
                    }
                    .padding()
                    
                }
                
            }
                
            
        }
        
    }
    
    var infoView: some View {
        
        Form{
    
            Section() {
                
                //VStack{
                
                    HStack{
                        Image(systemName: "arrow.triangle.swap")
                            .foregroundColor(color)
                            .onTapGesture {
                                showColorSelector.toggle()
                            }
                            .imageScale(.medium)
                        Divider()
                        TextField("", text: $title).modifier(ClearButton(text: $title))
                    }
                    
                    if showColorSelector {
                        //Divider()
                        ColorSelectorView(selectedColor: $color)
                    }
                    
                //}
                HStack{
                    TrackGroupRawView(trackGroup: trackGroup)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    showGroupSelection = true
                }
            }
            

            Section(header: Text("Description")) {
                
                ZStack {
                    TextEditor(text: $info)
                    Text(info).opacity(0).padding(.all, 8)
                }
                
            }
            
            Section(header: Text("Location")) {
                
                HStack{
                    
                    ZStack {
                        TextEditor(text: $locationString)
                        Text(locationString).opacity(0).padding(.all, 8)
                    }
                    .modifier(LightText())
                    
                    if locationString.isEmpty {
                        Button(action: {
                            
                            if let statistics = statistics {
                                
                                let centerPoint = statistics.centerPoint
                                
                                getDescriptionByCoordinates(latitude: centerPoint.latitude, longitude: centerPoint.longitude, handler: fillLocationString)
                                
                            }
                            
                        }) {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .font(Font.title3.weight(.light))
                                .foregroundColor(.secondary)
                        }
                    }                    
                    
                }
                .contextMenu {
                    Button {
                        let pasteBoard = UIPasteboard.general
                        pasteBoard.string = locationString
                    } label: {
                        Label("Copy", systemImage: "doc.on.clipboard")
                    }
                }
                
            }
            
            
            Section(header: Text("Statistics")) {
                
//                Text("\(statistics?.points.count ?? 0) points")
//                    .modifier(SecondaryInfo())
                
                HStack{
                    
                    VStack {
                        HStack{
                            Image(systemName: "hare")
                        }
                        .padding(.bottom, 5)
                        
                        HStack {
                            Text("max")
                            Text(" \(statistics?.maxSpeed.localeSpeedString ?? "")")
                        }
                        
                        HStack {
                            Text("avg")
                            Text(" \(statistics?.averageSpeed.localeSpeedString ?? "")")
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
                                Image(systemName: "arrow.up.right")
                                Text("\(statistics?.maxAltitude ?? 0)")
                            }
                            Text("(\((statistics?.maxAltitude ?? 0) - (statistics?.minAltitude ?? 0)))" + " m")
                        }
                        
                    }
                    
                }
                .modifier(LightText())
                .padding()
            }
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
        
    }
    
    func delete() {
        Track.deleteTrack(track: track, moc: moc)
    }
    
    func save() {
        
        Track.saveTrack(track: track,
                        moc: moc,
                        title: title,
                        info: info,
                        locationString: locationString,
                        color: color.description,
                        trackGroup: trackGroup)
        
        if trackGroupOnAppear != trackGroup {
            //dont refresh ID because app crashes if group was changed
            //(only real device, on simulator - everything ok)
        } else {
            trackListRefreshID = UUID()
        }
        
    }
    
    func fillLocationString(adressString: String) {
            locationString = adressString
    }
    
}

//struct TrackDetailsView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackDetailsView()
//    }
//}
