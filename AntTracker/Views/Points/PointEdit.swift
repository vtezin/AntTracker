//
//  PointEdit.swift
//  AntTracker
//
//  Created by test on 13.05.2021.
//

import SwiftUI
import CoreLocation

struct PointEdit: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var clManager: LocationManager
    
    @AppStorage("lastUsedPointColor") var lastUsedPointColor: String = "orange"
    
    let point: Point?
    
    @State var dateAdded = Date()
    
    @State var coordinate: CLLocationCoordinate2D
    
    @State private var title = "New point"
    @State private var color = Color.orange
    
    @State private var showQuestionBeforeDelete = false
    
    @Binding var pointsWasChanged: Bool
    
    var body: some View {
        
        NavigationView{
            
            Form{
                
                Section(header: Text("Title")) {
                    TextField("", text: $title)
                        .modifier(ClearButton(text: $title))
                }
                
                Section(header: Text("Color")) {
                    ColorSelectorView(selectedColor: $color)
                }
                
                Section(header: Text("Coordinate")) {
                    
                    HStack{
                        
                        Text(coordinate.coordinateStrings[0])
                        
                        Spacer()
                        
                        Button(action: {
                            
                            let pasteBoard = UIPasteboard.general
                            pasteBoard.string = coordinate.coordinateStrings[0]
                            
                        }) {
                            Image(systemName: "doc.on.clipboard")
                        }
                        
                    }
                }
                
                Section(header: Text("Distance from here")) {
                    Text(localeDistanceString(distanceMeters: clManager.location.distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))))
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
                    
                    VStack{
                        Text(dateAdded.dateString())
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    
                }
                
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }
               
                
            }
            .alert(isPresented:$showQuestionBeforeDelete) {
                Alert(title: Text("Delete this point?"), message: Text(""), primaryButton: .destructive(Text("Delete")) {
                    
                    delete()
                    presentationMode.wrappedValue.dismiss()
                    
                }, secondaryButton: .cancel())
            }
            
            .onAppear{
                if point != nil {
                    title = point!.title
                    color = Color.getColorFromName(colorName: point!.color)
                    coordinate = CLLocationCoordinate2D(latitude: point!.latitude, longitude: point!.longitude)
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
            pointForSave.latitude = coordinate.latitude
            pointForSave.longitude = coordinate.longitude
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
