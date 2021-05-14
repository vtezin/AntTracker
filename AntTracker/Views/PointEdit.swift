//
//  PointEdit.swift
//  AntTracker
//
//  Created by test on 13.05.2021.
//

import SwiftUI

struct PointEdit: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    
    @AppStorage("lastUsedPointColor") var lastUsedPointColor: String = "orange"
    
    let point: Point?
    
    @State var latitude: Double
    @State var longitude: Double
    
    @State private var title = "New point"
    @State private var color = Color.orange
    
    
    var body: some View {
        
        NavigationView{
            
            Form{
                
                Section(header: Text("Title")) {
                    TextField("title", text: $title)
                }
                
                Section(header: Text("Color ")) {
                    ColorSelectorView(selectedColor: $color)
                }
                
            }
            .navigationBarTitle(Text(point == nil ? "New point" : title), displayMode: .inline)
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
            
            .toolbar {
                
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }
                
                ToolbarItem(placement: .bottomBar) {
                    
                    Text(dateAddedString)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }
                
            }
            
            .onAppear{
                if point != nil {
                    title = point!.title
                    color = Color.getColorFromName(colorName: point!.color)
                    latitude = point!.latitude
                    longitude = point!.longitude
                }
            }
            
        }
        
    }
    
    var dateAddedString: String {
        
        if point == nil {
            return ""
        } else {
            return "created:" + point!.dateAdded.dateString()
        }
        
    }
    
    func save() {
        
        var pointForSave: Point
        
        if point == nil {
            pointForSave = Point(context: self.moc)
            pointForSave.id = UUID()
            pointForSave.dateAdded = Date()
            pointForSave.latitude = latitude
            pointForSave.longitude = longitude
        } else {
            pointForSave = point!
            lastUsedPointColor = color.description
        }
        
        pointForSave.title = title
        pointForSave.color = color.description
        
        try? moc.save()
        
        
    }
    
}

//struct PointEdit_Previews: PreviewProvider {
//    static var previews: some View {
//        PointEdit(point: nil)
//    }
//}
