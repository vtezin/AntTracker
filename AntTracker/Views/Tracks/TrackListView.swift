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
    @State private var showingAddGroupView = false
    
    @State private var trackListRefreshID = UUID() //for force refreshing
    
    init(activePage: Binding<ContentView.pages>) {
        self._activePage = activePage
    }
    
    var body: some View {
        
        NavigationView {
            
            List{
                
                //groups
                ForEach(groups, id: \.id) { group in
                    
                    NavigationLink(destination:
                                    TrackGroupView(group: group, activePage: $activePage)
                                    .environment(\.managedObjectContext, moc)) {
                        
                        HStack{
                            
                            ZStack {
                                Image(systemName: group.wrappedImageSymbol)
                                    .font(Font.title3.weight(.light))
                                    .foregroundColor(.secondary)
                                Image(systemName: "bicycle")
                                    .font(Font.title3.weight(.light))
                                    .opacity(0)
                            }
                            
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
                                
                .actionSheet(isPresented: $showQuestionBeforeDeleteGroup) {
                    actionSheetForDelete(title: "Delete this group? (all tracks are saved and become tracks outside the groups)") {
                        deleteGroup(at: indexSetToDeleteGroup)
                    } cancelAction: {
                        showQuestionBeforeDeleteGroup = false
                    }
                }
                
                
                ForEach(tracks, id: \.id) { track in
                    
                    NavigationLink(destination:
                                    TrackDetailView(track: track, activePage: $activePage, trackListRefreshID: $trackListRefreshID)
                                    .environment(\.managedObjectContext, moc)) {
                        
                        TrackRawView(track: track)
                        
                    }
                    
                }
                .onDelete(perform: { indexSet in
                    showQuestionBeforeDeleteTrack = true
                    indexSetToDelete = indexSet
                })
                
                .actionSheet(isPresented: $showQuestionBeforeDeleteTrack) {
                    actionSheetForDelete(title: "Delete this track?") {
                        for offset in indexSetToDelete! {
                            Track.deleteTrack(track: tracks[offset], moc: moc)
                        }
                    } cancelAction: {
                        showQuestionBeforeDeleteTrack = false
                    }
                }
                
                
            }
            .id(trackListRefreshID)
            .sheet(isPresented: $showingAddGroupView) {
                TrackGroupDetailView(group: nil)
            }
                        
            .navigationBarTitle("Tracks", displayMode: .inline)
            .navigationViewStyle(StackNavigationViewStyle())
            
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
                    showingAddGroupView = true
                }) {
                    Image(systemName: "folder.badge.plus")
                        .modifier(NavigationButton())
                })
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
        
    }
    
}

extension TrackListView {
        
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
