//
//  PointGroupSelectionView.swift
//  AntTracker
//
//  Created by test on 06.09.2021.
//

import SwiftUI

struct PointGroupSelectionView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(entity: PointGroup.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \TrackGroup.dateOfLastChange, ascending: false)]) var groups:FetchedResults<PointGroup>
    
    @Binding var selectedGroup: PointGroup?
    
    //adding new group
    @State private var titleForNewGroup = ""
    
    //renaming group
    @State private var showAlertForGroupRenaming = false
    @State private var groupForRenaming: TrackGroup?
    
    var body: some View {
        
        List{
            
            ForEach(groups, id: \.id) { group in
                HStack{
                    PointGroupRawView(group: group)
                }
                .onTapGesture{
                    selectedGroup = group
                    presentationMode.wrappedValue.dismiss()
                }

            }
            
            PointGroupRawView(group: nil)
            .onTapGesture{
                selectedGroup = nil
                presentationMode.wrappedValue.dismiss()
            }

        }
        .navigationBarTitle("Point groups", displayMode: .inline)
        .navigationBarItems(trailing: EditButton())
        .navigationViewStyle(StackNavigationViewStyle())
        
    }
}

//struct PointGroupSelectionView_Previews: PreviewProvider {
//    static var previews: some View {
//        PointGroupSelectionView()
//    }
//}
