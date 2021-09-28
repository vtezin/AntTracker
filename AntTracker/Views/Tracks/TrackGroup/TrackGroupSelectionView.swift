//
//  TrackGroupsView.swift
//  AntTracker
//
//  Created by test on 25.05.2021.
//

import SwiftUI

struct TrackGroupSelectionView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(entity: TrackGroup.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \TrackGroup.dateOfLastChange, ascending: false)]) var groups:FetchedResults<TrackGroup>
    
    @Binding var selectedGroup: TrackGroup?
    
    //adding new group
    @State private var titleForNewGroup = ""
    
    //renaming group
    @State private var showAlertForGroupRenaming = false
    @State private var groupForRenaming: TrackGroup?
    
    var body: some View {
        
        NavigationView{
            
            List{
                
                ForEach(groups, id: \.id) { group in
                    HStack{
                        TrackGroupRawView(trackGroup: group)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture{
                        selectedGroup = group
                        presentationMode.wrappedValue.dismiss()
                    }
                    
                }
                
                HStack{
                    TrackGroupRawView(trackGroup: nil)
                }
                .contentShape(Rectangle())
                .onTapGesture{
                    selectedGroup = nil
                    presentationMode.wrappedValue.dismiss()
                }
                
            }
            .navigationBarTitle("Select group", displayMode: .inline)
            .navigationViewStyle(StackNavigationViewStyle())
            
            .navigationBarItems(
                trailing:
                    NavigationLink(destination: TrackGroupDetailView(group: nil)) {
                        Image(systemName: "folder.badge.plus")
                            .modifier(NavigationButton())
                }
            )
            
        }
        
        
    }
    
}

//struct TrackGroupsView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackGroupsView()
//    }
//}
