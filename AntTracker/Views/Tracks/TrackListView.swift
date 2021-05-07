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
    @State private var showingQuestionBeforDelete = false
    
    var body: some View {
        
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
                showingQuestionBeforDelete = true
                indexSetToDelete = indexSet
            })
        }
        
        .navigationBarTitle("Tracks", displayMode: .inline)
//        .navigationBarBackButtonHidden(true)
//        .navigationBarItems(leading: Button(action: {
//            self.presentationMode.wrappedValue.dismiss()
//        }) {
//            HStack{
//                Image(systemName: "chevron.left")
//                Text("     ")
//                //Image(systemName: "ant")
//            }
//        })
        
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
