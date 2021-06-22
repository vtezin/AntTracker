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
    
    @AppStorage("lastUsedTrackColor") var lastUsedTrackColor: String = "orange"
    
    @State var title = ""
    @State var info = ""
    @State var color: Color = .orange
    @State var trackGroup: TrackGroup?
    
    @State private var showQuestionBeforeDelete = false
    
    init(activePage: Binding<ContentView.pages>) {
        
        _activePage = activePage
        
        if let track = CurrentTrack.currentTrack.trackCoreData {
            _title = State(initialValue: track.title)
            _info = State(initialValue: track.info)
            _color = State(initialValue: Color.getColorFromName(colorName: track.color))
            _trackGroup = State(initialValue: track.trackGroup)
        }
        
        
    }
    
    var body: some View {
        
        NavigationView{
            
            Form{
                
                Section() {
                    TextField("", text: $title).modifier(ClearButton(text: $title))
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
                        TrackGroupRawView(trackGroup: trackGroup)
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
            
            .alert(isPresented:$showQuestionBeforeDelete) {
                Alert(title: Text("Delete this track?"), message: Text("There is no undo"), primaryButton: .destructive(Text("Delete")) {
                    
                    delete()
                    activePage = ContentView.pages.main
                    
                }, secondaryButton: .cancel())
            }
            
        }
        
        
        
    }
    
    func save() {
        
        let track = currentTrack.trackCoreData!
        
        track.fillByCurrentTrackData(moc: moc)
        lastUsedTrackColor = color.description
        
        track.title = title
        track.info = info
        track.color = color.description
        track.trackGroup = trackGroup
        
        try? moc.save()
        
        currentTrack.reset()
        
    }
    
    func delete() {
        Track.deleteTrack(track: currentTrack.trackCoreData!, moc: moc)
    }
    
}

//struct CompleteRecordTrack_Previews: PreviewProvider {
//    static var previews: some View {
//        CompleteRecordTrack()
//    }
//}