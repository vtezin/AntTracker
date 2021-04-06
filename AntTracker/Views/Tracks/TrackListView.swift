//
//  TrackListView.swift
//  JustMap
//
//  Created by test on 26.03.2021.
//

import SwiftUI

struct TrackListView: View {
    
    @Binding var isNavigationBarHidden: Bool
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Track.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Track.startDate, ascending: true)]) var tracks:FetchedResults<Track>
    
    @State private var indexSetToDelete: IndexSet?
    @State private var showingQuestionBeforDelete = false
    
    var body: some View {
        
        
        List{
            
            ForEach(tracks, id: \.self) { track in
                
                NavigationLink(destination: TrackView(track: track)) {
                    VStack(alignment: .leading){
                        Text(track.title)
                        Text(track.info)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        HStack{
                            Text(track.startDate.dateString())
                            Spacer()
                            Text("\(track.totalDistance) m")
                        }
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    }
                    
                    
                }
                
            }
            .onDelete(perform: { indexSet in
                showingQuestionBeforDelete = true
                indexSetToDelete = indexSet
            })
        }
        
        
        .navigationBarTitle("Tracks", displayMode: .inline)
        .onAppear {
            isNavigationBarHidden = false
        }
        .onDisappear{
            isNavigationBarHidden = true
        }
        .alert(isPresented:$showingQuestionBeforDelete) {
            Alert(title: Text("Delete this track?"), message: Text("There is no undo"), primaryButton: .destructive(Text("Delete")) {
                
                for offset in indexSetToDelete! {
                    Track.deleteTrack(track: tracks[offset], moc: moc)
                }
                
            }, secondaryButton: .cancel())
        }
        
    }
}

//struct TrackListView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackListView()
//    }
//}
