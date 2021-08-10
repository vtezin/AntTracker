//
//  TrackGroupDetailView.swift
//  AntTracker
//
//  Created by test on 09.08.2021.
//

import SwiftUI

struct TrackGroupDetailView: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    
    let group: TrackGroup?
    
    @State private var title = "New group"
    @State private var imageSymbol = "folder"
    
    @State private var showImageSymbolSelector = false
    
    init(group: TrackGroup?) {
        
        self.group = group
        
        if let group = group {
            _title = State(initialValue: group.title)
            _imageSymbol = State(initialValue: group.wrappedImageSymbol)
        } else {
            _showImageSymbolSelector = State(initialValue: true)
        }
        
    }
    
    var body: some View {
        
        NavigationView {
            
            Form {
                
                Section{
                    
                    HStack{
                        TextField("Title", text: $title)
                        Divider()
                        Image(systemName: imageSymbol)
                            .imageScale(.large)
                            .onTapGesture {
                                withAnimation{
                                    showImageSymbolSelector = true
                                }
                            }
                    }
                    .font(.title2)
                    
                    if showImageSymbolSelector {
                        ImageSymbolSelectorView(selectedImage: $imageSymbol,
                                                showSelectorOnRequestor: $showImageSymbolSelector)
                    }
                    
                }
                
            }
            
            .navigationBarTitle("Group", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Cancel")
            },
            trailing: Button(action: {
                save()
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Save")
            })
            
        }
        
        
    }
    
    func save() {
        
        var groupForSave: TrackGroup
        
        if group == nil {
            groupForSave = TrackGroup(context: moc)
            groupForSave.id = UUID()
        } else {
            groupForSave = group!
        }
        
        groupForSave.dateOfLastChange = Date()
        groupForSave.title = title
        groupForSave.imageSymbol = imageSymbol
        
        try? moc.save()
        
    }
    
    
}

//struct TrackGroupDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackGroupDetailView()
//    }
//}
