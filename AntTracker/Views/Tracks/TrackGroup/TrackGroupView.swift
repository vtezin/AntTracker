//
//  TrackGroupView.swift
//  AntTracker
//
//  Created by test on 26.05.2021.
//

import SwiftUI

struct TrackGroupView: View {
    
    @Binding var activePage: ContentView.pages
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    
    var tracks: FetchRequest<Track>
    
    @State private var showingGroupDetailView = false
    @State private var trackListRefreshID = UUID() //for force refreshing
    
    init(group: TrackGroup, activePage: Binding<ContentView.pages>) {
        
        self.group = group
        tracks = FetchRequest(entity: Track.entity(),
                      sortDescriptors: [NSSortDescriptor(keyPath: \Track.startDate, ascending: false)],
                      predicate: NSPredicate(format: "trackGroup == %@", group))
        _activePage = activePage
    
        
    }
    
    let group: TrackGroup
        
    var body: some View {
        
        List{
            
            ForEach(tracks.wrappedValue, id: \.id) { track in

                NavigationLink(destination: TrackDetailsView(track: track, activePage: $activePage, trackListRefreshID: $trackListRefreshID)) {
                    TrackRawView(track: track)
                }

            }
            
        }
        .id(trackListRefreshID)
        
        .sheet(isPresented: $showingGroupDetailView) {
            TrackGroupDetailView(group: group)
        }
        .navigationBarTitle(group.title, displayMode: .inline)
        .navigationBarItems(
            trailing: Button(action: {
                showingGroupDetailView = true
            }) {
                Image(systemName: "info.circle")
            })
        
    }
    
    func renameGroup(title: String) {
        
            group.title = title
            try? moc.save()

    }
    
    
}

//struct TrackGroupView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackGroupView()
//    }
//}
