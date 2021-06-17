//
//  TrackPropertiesView.swift
//  AntTracker
//
//  Created by test on 25.05.2021.
//

import SwiftUI

struct SavingNewTrackToCoreDataView: View {
    
    @Binding var activePage: ContentView.pages
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var currentTrack: CurrentTrack
    
    @AppStorage("lastUsedTrackColor") var lastUsedTrackColor: String = "orange"
        
    @State var viewInitedByExistingTrack = false
    
    @State var title = ""
    @State var info = ""
    @State var color: Color = .orange
    @State var trackGroup: TrackGroup?
    
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
                
                
            }
            
            .navigationBarTitle(Text("Save track"), displayMode: .inline)
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
            .onAppear{

//                if let track = track {
//
//                    if !viewInitedByExistingTrack {
//                        title = track.title
//                        info = track.info
//                        color = Color.getColorFromName(colorName: track.color)
//                        trackGroup = track.trackGroup
//                        viewInitedByExistingTrack = true
//                    }
//
//                } else {
                    //presets for new track
                    title = Date().dateString()
                    color = Colors.nextColor(fromColorWhithName: lastUsedTrackColor)
 //               }
        }
        
            
        }
        
    }
    
    func save() {
        
        let trackForSave = Track(context: moc)
        trackForSave.id = UUID()
        trackForSave.fillByCurrentTrackData(moc: moc)
        lastUsedTrackColor = color.description
        
        trackForSave.title = title
        trackForSave.info = info
        trackForSave.color = color.description
        trackForSave.trackGroup = trackGroup
        
        try? moc.save()
        
        currentTrack.trackCoreData = trackForSave
        
    }
    
}

//struct TrackPropertiesView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackPropertiesView()
//    }
//}
