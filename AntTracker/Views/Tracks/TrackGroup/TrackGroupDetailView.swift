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
    
    @State private var title = ""
    @State private var info = ""
    @State private var imageSymbol = SFSymbolsAPI.groupDefaultImageSymbol
    
    @State private var showImageSymbolSelector = true
    
    enum FirstResponders: Int {
        case title
    }
    @State var firstResponder: FirstResponders?
    
    init(group: TrackGroup?) {
        
        self.group = group
        
        if let group = group {
            _title = State(initialValue: group.wrappedTitle)
            _info = State(initialValue: group.wrappedInfo)
            _imageSymbol = State(initialValue: group.wrappedImageSymbol)
        } else {
            _showImageSymbolSelector = State(initialValue: true)
            _firstResponder = State(initialValue: .title)
        }
        
    }
    
    var body: some View {
        
        NavigationView {
            
            Form {
                
                Section{
                    
                    HStack{
                        TextField("Title", text: $title)
                            .firstResponder(id: FirstResponders.title, firstResponder: $firstResponder, resignableUserOperations: .all)
                            .modifier(ClearButton(text: $title))
                    }
                    
                    if showImageSymbolSelector {
                        ImageSymbolSelectorView(selectedImage: $imageSymbol,
                                                imageSymbolSet: SFSymbolsAPI.groupImageSymbols)
                    }
                    
                }
                
                Section(header: Text("Description")) {
                    
                    ZStack {
                        TextEditor(text: $info)
                        Text(info).opacity(0).padding(.all, 8)
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
        
        TrackGroup.addUpdateGroup(group: group,
                                  moc: moc,
                                  title: title,
                                  info: info,
                                  imageSymbol: imageSymbol)
        
    }
        
}

//struct TrackGroupDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackGroupDetailView()
//    }
//}
