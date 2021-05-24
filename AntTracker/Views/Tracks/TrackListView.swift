//
//  TrackListView.swift
//  JustMap
//
//  Created by test on 26.03.2021.
//

import SwiftUI

struct TrackListView: View {
    
    @Binding var isNavigationBarHidden: Bool
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Track.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Track.startDate, ascending: false)]) var tracks:FetchedResults<Track>
    
    @State private var indexSetToDelete: IndexSet?
    @State private var showQuestionBeforDelete = false
    
    var body: some View {
        
        VStack{
            
            List{
                
                ForEach(tracks, id: \.self) { track in
                    
                    NavigationLink(destination: TrackView(track: track)) {
                        
                        VStack(alignment: .leading) {
                            
                            Text(track.title)
                            HStack{
                                VStack(alignment: .leading){
                                    Text(track.info)
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing){
                                    Text(track.startDate.dateString())
                                    Text(localeDistanceString(distanceMeters: Double(track.totalDistance)))
                                }
                                .modifier(SecondaryInfo())
                            }
                            
                        }
                        
                        
                    }
                    
                }
                .onDelete(perform: { indexSet in
                    showQuestionBeforDelete = true
                    indexSetToDelete = indexSet
                })
            }
            .alert(isPresented:$showQuestionBeforDelete) {
                Alert(title: Text("Delete this track?"), message: Text("There is no undo"), primaryButton: .destructive(Text("Delete")) {
                    
                    for offset in indexSetToDelete! {
                        Track.deleteTrack(track: tracks[offset], moc: moc)
                    }
                    
                }, secondaryButton: .cancel())
            }
            
        }
        .navigationBarTitle("Tracks", displayMode: .inline)
        
        .onAppear {
            isNavigationBarHidden = false
        }
        .onDisappear{
            isNavigationBarHidden = true
        }
        
    }
}

//struct TrackListView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackListView()
//    }
//}
