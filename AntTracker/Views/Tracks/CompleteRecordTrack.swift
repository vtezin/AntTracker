//
//  CompleteRecordTrack.swift
//  AntTracker
//
//  Created by test on 19.06.2021.
//

import SwiftUI

struct CompleteRecordTrack: View {
    
    @Binding var activePage: ContentView.pages
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var currentTrack: CurrentTrack
    @EnvironmentObject var clManager: LocationManager
    
    @State var title = ""
    @State var info = ""
    @State var locationString = ""
    @State var color: Color = .orange
    @State var trackGroup: TrackGroup?
    
    @State private var showQuestionBeforeDelete = false
    @State private var showColorSelector = false
    
    enum FirstResponders: Int {
        case title
    }
    @State var firstResponder: FirstResponders?
    
    init(activePage: Binding<ContentView.pages>) {
        
        _activePage = activePage
        
        if let track = CurrentTrack.currentTrack.trackCoreData {
            _title = State(initialValue: track.wrappedTitle)
            _info = State(initialValue: track.wrappedInfo)
            _color = State(initialValue: Color.getColorFromName(colorName: track.wrappedColor))
            _trackGroup = State(initialValue: track.trackGroup)
        }
        
        
    }
    
    var body: some View {
        
        NavigationView{
            
            Form{
                
                Section() {
                    
                    VStack{
                    
                        HStack{
                            Image(systemName: "arrow.triangle.swap")
                                .foregroundColor(color)
                                .onTapGesture {
                                    showColorSelector.toggle()
                                }
                                .imageScale(.medium)
                            Divider()
                            TextField("", text: $title)
                                .firstResponder(id: FirstResponders.title, firstResponder: $firstResponder, resignableUserOperations: .all)
                                .modifier(ClearButton(text: $title))
                        }
                        
                        if showColorSelector {
                            Divider()
                            ColorSelectorView(selectedColor: $color)
                        }
                        
                    }
                }
                
                Section(header: Text("Description")) {
                    
                    ZStack {
                        TextEditor(text: $info)
                        Text(info).opacity(0).padding(.all, 8)
                    }
                    
                }
                
                Section(header: Text("Track group")) {
                    NavigationLink(destination: TrackGroupSelectionView(selectedGroup: $trackGroup)) {
                        TrackGroupRawView(trackGroup: trackGroup)
                    }
                }
                
                Section(header: Text("Location")) {
                    
                    HStack{
                        
                        ZStack {
                            TextEditor(text: $locationString)
                            Text(locationString).opacity(0).padding(.all, 8)
                        }
                        
                    }
                    
                }
                
                Button(action: {
                    showQuestionBeforeDelete = true
                }) {
                    Text("Delete track")
                        .foregroundColor(.red)
                }
                
            }
            .navigationBarTitle(Text("Complete track"), displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                activePage = ContentView.pages.main
            }) {
                Text("Cancel")
            },
            trailing: Button(action: {
                save()
                activePage = ContentView.pages.main
            }) {
                Text("Done")
            })
            
            .actionSheet(isPresented: $showQuestionBeforeDelete) {
                
                actionSheetForDelete(title: "Delete this track?") {
                    delete()
                    activePage = ContentView.pages.main
                } cancelAction: {
                    showQuestionBeforeDelete = false
                }

            }
            .onAppear{
                
                firstResponder = .title
                
                if CurrentTrack.currentTrack.points.count > 0 {
                    
                    let startPoint = CurrentTrack.currentTrack.points[0].location
                    
                    getDescriptionByCoordinates(latitude: startPoint.coordinate.latitude,
                                                longitude: startPoint.coordinate.longitude,
                                                handler: fillLocationString,
                                                fullAdress: false)
                    
                }
                
            }
            
        }
        
    }
    
    func save() {
        
        let track = currentTrack.trackCoreData!
        
        track.fillByCurrentTrackData(moc: moc)
        
        Track.saveTrack(track: track,
                        moc: moc,
                        title: title,
                        info: info,
                        locationString: locationString,
                        color: color.description,
                        trackGroup: trackGroup)
        
        currentTrack.reset()
        clManager.trackRecordingState = .none
        
    }
    
    func delete() {
        Track.deleteTrack(track: currentTrack.trackCoreData!, moc: moc)
        clManager.trackRecordingState = .none
    }
    
    func fillLocationString(adressString: String) {
            locationString = adressString
    }
    
}

//struct CompleteRecordTrack_Previews: PreviewProvider {
//    static var previews: some View {
//        CompleteRecordTrack()
//    }
//}
