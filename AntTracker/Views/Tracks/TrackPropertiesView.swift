//
//  TrackPropertiesView.swift
//  AntTracker
//
//  Created by test on 25.05.2021.
//

import SwiftUI

struct TrackPropertiesView: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    
    @AppStorage("lastUsedTrackColor") var lastUsedTrackColor: String = "orange"
    
    let track: Track?
    @State var viewInitedByExistingTrack = false
    
    @State var title = ""
    @State var info = ""
    @State var color: Color = .orange
    @State var trackGroup: TrackGroup?
    
    @Binding var mapSettingsChanged: Bool
    
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
                            Text(trackGroup?.title ?? "")
                    }
                }
                
                
            }
            
            .navigationBarTitle(Text(track == nil ? "Save track" : "Edit track"), displayMode: .inline)
            .navigationBarItems(
                trailing: Button(action: {
                    save()
                    mapSettingsChanged.toggle()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Done")
                })
            .onAppear{

                if let track = track {
                    
                    if !viewInitedByExistingTrack {
                        title = track.title
                        info = track.info
                        color = Color.getColorFromName(colorName: track.color)
                        trackGroup = track.trackGroup
                        viewInitedByExistingTrack = true
                    }
                    
                } else {
                    //presets for new track
                    title = Date().dateString()
                    color = Colors.nextColor(fromColorWhithName: lastUsedTrackColor)
                }
        }
        
            
        }
        
    }
    
    func save() {
        
        var trackForSave: Track
        
        if track == nil {
            trackForSave = Track(context: moc)
            trackForSave.id = UUID()
            trackForSave.fillByCurrentTrackData(moc: moc)
            lastUsedTrackColor = color.description
        } else {
            trackForSave = track!
        }
        
        trackForSave.title = title
        trackForSave.info = info
        trackForSave.color = color.description
        trackForSave.trackGroup = trackGroup
        
        try? moc.save()
        
        
    }
    
}

//struct TrackPropertiesView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackPropertiesView()
//    }
//}
