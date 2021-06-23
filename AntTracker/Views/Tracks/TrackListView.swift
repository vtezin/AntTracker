//
//  TrackListView.swift
//  JustMap
//
//  Created by test on 26.03.2021.
//

import SwiftUI

struct TrackListView: View {
    
    @Binding var activePage: ContentView.pages
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var currentTrack: CurrentTrack
    
    @FetchRequest(entity: Track.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Track.startDate, ascending: false)],
                  predicate: NSPredicate(format: "trackGroup == nil")) var tracks: FetchedResults<Track>
    
    @FetchRequest(entity: TrackGroup.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \TrackGroup.dateOfLastChange, ascending: false)]) var groups: FetchedResults<TrackGroup>
    
    @State private var indexSetToDelete: IndexSet?
    @State private var indexSetToDeleteGroup: IndexSet?
    @State private var showQuestionBeforeDeleteTrack = false
    @State private var showQuestionBeforeDeleteGroup = false
    
    //adding new group
    @State private var showAlertForGroupName = false
    
    init(activePage: Binding<ContentView.pages>) {
        self._activePage = activePage
    }
    
    var body: some View {
        
        NavigationView {
            
            //Form{
            
            List{
                
                //groups
                ForEach(groups, id: \.id) { group in
                    
                    NavigationLink(destination:
                                    TrackGroupView(group: group)) {
                        
                        HStack{
                            Image(systemName: "folder")
                                .foregroundColor(.secondary)
                            Text(group.title)
                            Spacer()
                            Text("\(group.tracksArray.count)")
                                .modifier(SecondaryInfo())
                        }
                    }
                    
                }
                .onDelete(perform: { indexSet in
                    showQuestionBeforeDeleteGroup = true
                    indexSetToDeleteGroup = indexSet
                })
                .alert(isPresented:$showQuestionBeforeDeleteGroup) {
                    Alert(title: Text("Delete this group?"),
                          message: Text("all tracks are saved and become tracks outside the groups"), primaryButton: .destructive(Text("Delete")) {
                            
                            deleteGroup(at: indexSetToDeleteGroup)
                            
                          }, secondaryButton: .cancel())
                }
                
                
                ForEach(tracks, id: \.id) { track in
                    
                    NavigationLink(destination:
                                    TrackDetailsView(track: track)
                                    .environment(\.managedObjectContext, moc)) {
                        
                        TrackRawView(track: track)
                        
                    }
                    
                }
                .onDelete(perform: { indexSet in
                    showQuestionBeforeDeleteTrack = true
                    indexSetToDelete = indexSet
                })
                .alert(isPresented:$showQuestionBeforeDeleteTrack) {
                    Alert(title: Text("Delete this track?"), message: Text("There is no undo"), primaryButton: .destructive(Text("Delete")) {
                        
                        for offset in indexSetToDelete! {
                            Track.deleteTrack(track: tracks[offset], moc: moc)
                        }
                        
                    }, secondaryButton: .cancel())
                }
                
            }
            .alert(isPresented: $showAlertForGroupName,
                   TextAlert(title: "Group title",
                             message: "",
                             text: "",
                             keyboardType: .default) { result in
                    if let text = result {
                        addGroup(title: text)
                    }
                   })
            
            
            //}
            .navigationBarTitle("Tracks", displayMode: .inline)
            
            .navigationBarItems(
                leading: Button(action: {
                    withAnimation{
                        activePage = .main
                    }
                }) {
                    HStack{
                        Image(systemName: "chevron.backward")
                        Text("Map")
                    }
                },
                trailing: Button(action: {
                    showAlertForGroupName = true
                }) {
                    Image(systemName: "folder.badge.plus")
                        .imageScale(.large)
                })
            
        }
        
    }
    
}

extension TrackListView {
    
    private func addGroup(title: String) {
        
        guard !title.isEmpty else {
            return
        }
        
        let newGroup = TrackGroup(context: moc)
        
        newGroup.title = title
        newGroup.id = UUID()
        newGroup.dateOfLastChange = Date()
        
        try? moc.save()
        
    }
    
    private func deleteGroup(at offsets: IndexSet?) {
        
        for offset in offsets! {
            // find this group in our fetch request
            let group = groups[offset]
            
            TrackGroup.deleteGroup(group: group, moc: moc)
            
        }
        
        // save the context
        try? moc.save()
        
    }
    
}

//struct TrackListView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackListView()
//    }
//}
