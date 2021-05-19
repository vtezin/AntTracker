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
    
    @State var dateAdded = Date()
    
    @State var latitude: Double
    @State var longitude: Double
    
    @State private var title = "New point"
    @State private var color = Color.orange
    
    @State private var showQuestionBeforeDelete = false
    
    @Binding var pointsWasChanged: Bool
    
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
                    Button(action: {
                        if point != nil {
                            showQuestionBeforeDelete = true
                        } else {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Image(systemName: "trash")
                    }
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }
                
                ToolbarItem(placement: .bottomBar) {
                    
                    Text(dateAdded.dateString())
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }
               
                
            }
            .alert(isPresented:$showQuestionBeforeDelete) {
                Alert(title: Text("Delete this point?"), message: Text("There is no undo"), primaryButton: .destructive(Text("Delete")) {
                    
                    delete()
                    presentationMode.wrappedValue.dismiss()
                    
                }, secondaryButton: .cancel())
            }
            
            .onAppear{
                if point != nil {
                    title = point!.title
                    color = Color.getColorFromName(colorName: point!.color)
                    dateAdded = point!.dateAdded
                }
            }
            
        }
        
        
    }
    
    func delete() {
        
        moc.delete(point!)
        try? moc.save()
        
        pointsWasChanged = true
        
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
        
        pointsWasChanged = true
        
    }
    
}

//struct PointEdit_Previews: PreviewProvider {
//    static var previews: some View {
//        PointEdit(point: nil)
//    }
//}
