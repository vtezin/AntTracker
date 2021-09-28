//
//  PointGroupDetailView.swift
//  AntTracker
//
//  Created by test on 06.09.2021.
//

import SwiftUI

struct PointGroupDetailView: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var pointListRefreshID: UUID
    
    let group: PointGroup?
    
    @State private var title = ""
    @State private var info = ""
    @State private var imageSymbol = SFSymbolsAPI.pointDefaultImageSymbol
    @State private var color: Color = AppConstants.defaultColor
    @State private var showOnMap = true
    
    @State private var showImageSymbolSelector = true
    @State private var showColorSelector = false
    
    enum FirstResponders: Int {
        case title
    }
    @State var firstResponder: FirstResponders?
    
    init(group: PointGroup?, pointListRefreshID: Binding<UUID>) {
        
        self.group = group
        
        if let group = group {
            _title = State(initialValue: group.wrappedTitle)
            _info = State(initialValue: group.wrappedInfo)
            _imageSymbol = State(initialValue: group.wrappedImageSymbol)
            _color = State(initialValue: Color.getColorFromName(colorName: group.wrappedColor))
            _showOnMap = State(initialValue: group.showOnMap)
        } else {
            _showImageSymbolSelector = State(initialValue: true)
            _showColorSelector = State(initialValue: true)
            _firstResponder = State(initialValue: .title)
        }
        
        _pointListRefreshID = pointListRefreshID
        
    }
    
    var body: some View {
        
        NavigationView {
            
            Form {
                
                Section{
                    
                    HStack{
                        Image(systemName: imageSymbol)
                            .foregroundColor(.white)
                            .imageScale(.medium)
                            .padding(10)
                            .background(color)
                            .clipShape(Circle())
                            .onTapGesture {
                                withAnimation {
                                    showColorSelector.toggle()
                                }
                            }
                        Divider()
                        TextField("", text: $title)
                            .firstResponder(id: FirstResponders.title, firstResponder: $firstResponder, resignableUserOperations: .all)
                            .modifier(ClearButton(text: $title))
                    }
                    
                    if showColorSelector {
                        VStack{
                            ColorSelectorView(selectedColor: $color,
                                              imageForSelectedColor: "circle.fill",
                                              imageForUnselectedColor: "circle")
                            ImageSymbolSelectorView(selectedImage: $imageSymbol, imageSymbolSet: SFSymbolsAPI.pointImageSymbols)
                        }
                    }
                    
                }
                
                Section(header: Text("Description")) {
                    
                    ZStack {
                        TextEditor(text: $info)
                        Text(info).opacity(0).padding(.all, 8)
                    }
                    
                }
                
                Toggle(isOn: $showOnMap.animation()) {
                    Text("Display on the map")
                }
                
            }
            
            .navigationBarTitle("Point group", displayMode: .inline)
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
        
        PointGroup.addUpdateGroup(group: group,
                                  moc: moc,
                                  title: title,
                                  info: info,
                                  imageSymbol: imageSymbol,
                                  color: color.description,
                                  showOnMap: showOnMap)
        
        pointListRefreshID = UUID()
        
    }
    
}

//struct PointGroupDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        PointGroupDetailView()
//    }
//}
