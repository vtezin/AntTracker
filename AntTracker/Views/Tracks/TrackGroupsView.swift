//
//  TrackGroupsView.swift
//  AntTracker
//
//  Created by test on 25.05.2021.
//

import SwiftUI

struct TrackGroupsView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: TrackGroup.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \TrackGroup.positionInList, ascending: true)]) var groups:FetchedResults<TrackGroup>
    
    @Binding var selectedGroup: TrackGroup?
    
    //deleting group
    @State private var indexSetToDelete: IndexSet?
    @State private var showQuestionBeforeDelete = false
    //adding new group
    @State private var titleForNewGroup = ""
    
    //renaming group
    @State private var showAlertForGroupRenaming = false
    @State private var groupForRenaming: TrackGroup?
    
    var body: some View {
        
        List{
            
            ForEach(groups, id: \.id) { group in
                HStack{
                    Text(group.title)
                    Spacer()
                }
                .onTapGesture{
                    selectedGroup = group
                    presentationMode.wrappedValue.dismiss()
                }
                .onLongPressGesture{
                    groupForRenaming = group
                    showAlertForGroupRenaming = true
                }

            }
            .onDelete(perform: { indexSet in
                showQuestionBeforeDelete = true
                indexSetToDelete = indexSet
            })
            .onMove(perform: moveGroup)
            
            
            HStack {
                TextField("new group...   ", text: $titleForNewGroup, onEditingChanged: { (changed) in })
                {
                    addGroup()
                }
                Spacer()
                
                if titleForNewGroup != "" {

                    Button(action: {
                        addGroup()
                        hideKeyboard()
                    }) {
//                        Text("ок")
//                            .padding(5)
//                            .overlay(
//                                Circle()
//                                    .stroke(Color.secondary,
//                                            lineWidth:1))
                        Image(systemName: "plus.circle")
                            .font(.title)
                            .padding()
                            .clipShape(Circle())
                    }
                    //.foregroundColor(Color.secondary)
                }
                
            }
            .alert(isPresented: $showAlertForGroupRenaming,
                   TextAlert(title: "Rename group",
                             message: "",
                             text: groupForRenaming?.title ?? "",
                             keyboardType: .default) { result in
                    if let text = result {
                        renameGroup(newTitle: text)
                    }
                   })
        }
        .navigationBarTitle("Track groups", displayMode: .inline)
        .navigationBarItems(trailing: EditButton())
        .alert(isPresented: $showQuestionBeforeDelete) {
            Alert(title: Text("Delete this group?"), message: Text("There is no undo"), primaryButton: .destructive(Text("Delete")) {
                    deleteGroup(at: indexSetToDelete)
            }, secondaryButton: .cancel())
        }
        
    }
    
    func addGroup() {
        
        guard !titleForNewGroup.isEmpty else {
            return
        }
        
        let newGroup = TrackGroup(context: moc)
        
        newGroup.title = titleForNewGroup
        newGroup.id = UUID()
        newGroup.positionInList = Int16(groups.count)
        
        try? moc.save()
        
        titleForNewGroup = ""

    }
    
    func renameGroup(newTitle: String) {
        
        if let group = groupForRenaming {
            group.title = newTitle
            try? moc.save()
        }

    }
    
    private func moveGroup(source: IndexSet, destination: Int) {
    
        let indexFrom = source.first!
        let indexTo = destination
        
        if indexFrom == indexTo {
            return
        }
        
        let groupForMoving = groups[indexFrom]

        groupForMoving.positionInList = Int16(indexTo)

        try? moc.save()
        
        refreshPositions()
        
    }
    
    private func refreshPositions() {
        var counter = 0
        for item in groups {
            item.positionInList = Int16(counter)
            counter += 1
        }
        try? moc.save()
    }
    
    func deleteGroup(at offsets: IndexSet?) {
        
        for offset in offsets! {
            // find this list in our fetch request
            let group = groups[offset]
            
            //erase group in all tracks
            group.prepareForDelete(moc: moc)
            
            // delete it from the context
            moc.delete(group)
        }
        
        // save the context
        try? moc.save()
        
        selectedGroup = nil
        
    }
    
    
}

//struct TrackGroupsView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackGroupsView()
//    }
//}
