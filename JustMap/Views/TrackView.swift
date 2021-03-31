//
//  TrackView.swift
//  JustMap
//
//  Created by test on 25.03.2021.
//

import SwiftUI

struct TrackView: View {
    
    //@Binding var isNavigationBarHidden: Bool
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    
    let track: Track
    
    @State var title = ""
    @State var info = ""
    @State var region = ""
    @State var showOnMap = false
    @State var color: Color = .primary
    
    var body: some View {
        
        //NavigationView{
            
            Form{
                
                Section(header: Text("Title")) {
                    TextField("", text: $title)
                }
                
                Section(header: Text("Description")) {
                    TextField("", text: $info)
                }
                
                Section(header: Text("Region")) {
                    TextField("", text: $region)
                }
                
                Section(header: Text("Info")) {
                    VStack(alignment: .leading){
                        Text("start:" + " " + track.startDate.dateString())
                        Text("finish:" + " "  + track.finishDate.dateString())
                        Text("distance:" + " "  + String(track.totalDistance))
                        Text("points:" + " "  + String(track.trackPointsArray.count))
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }
                
            }
            .onAppear{
                
                //isNavigationBarHidden = false
                
                title = track.title
                info = track.info
                region = track.region
                showOnMap = track.showOnMap
                
            }
            .navigationBarTitle(Text(track.title), displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Cancel")
            },
            trailing: Button(action: {
                save()
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Save")
            })
        //}
        
    }
    
    func save() {
        
        track.title = title
        track.info = info
        track.region = region
        track.showOnMap = showOnMap
        track.color = color.description
        
        try? self.moc.save()
        
    }
    
}

//struct TrackView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackView(track: Track())
//    }
//}
