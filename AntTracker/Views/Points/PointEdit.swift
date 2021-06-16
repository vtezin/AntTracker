//
//  PointEdit.swift
//  AntTracker
//
//  Created by test on 13.05.2021.
//

import SwiftUI
import CoreLocation

struct PointEdit: View {
    
    @Binding var activePage: ContentView.pages
    
    @Environment(\.managedObjectContext) var moc
    
    @EnvironmentObject var constants: GlobalAppVars
    
    @AppStorage("lastUsedPointColor") var lastUsedPointColor: String = "orange"
    @AppStorage("lastUsedCLLatitude") var lastUsedCLLatitude: Double = 0
    @AppStorage("lastUsedCLLongitude") var lastUsedCLLongitude: Double = 0
    
    @State private var title: String = "New point"
    @State private var color: Color = Color.orange
    @State private var dateAdded: Date = Date()
    @State private var point: Point?
    @State private var coordinate = CLLocationCoordinate2D()
    
    @State private var showQuestionBeforeDelete = false
    
    var body: some View {
        
        NavigationView{
            
            Form{
                
                Section(header: Text("Title")) {
                    TextField("", text: $title)
                        .font(.title2)
                        .modifier(ClearButton(text: $title))
                        .foregroundColor(color)
                    ColorSelectorView(selectedColor: $color,
                                      imageForSelectedColor: "mappin.circle.fill",
                                      imageForUnselectedColor: "mappin.circle")
                    
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
                    Text(localeDistanceString(distanceMeters: CLLocation(latitude: lastUsedCLLatitude, longitude: lastUsedCLLongitude).distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))))
                }
                
                
            }
            
            .navigationBarTitle(Text(""), displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                activePage = ContentView.pages.main
            }) {
                Text("Cancel")
            },
            trailing: Button(action: {
                save()
                activePage = ContentView.pages.main
            }) {
                Text("Done")
            })
            
            .toolbar {
                
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
                
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        if point != nil {
                            showQuestionBeforeDelete = true
                        } else {
                            activePage = ContentView.pages.main
                        }
                    }) {
                        Image(systemName: "trash")
                    }
                }
                
                
            }
            .alert(isPresented:$showQuestionBeforeDelete) {
                Alert(title: Text("Delete this point?"), message: Text(""), primaryButton: .destructive(Text("Delete")) {
                    
                    delete()
                    activePage = ContentView.pages.main
                    
                }, secondaryButton: .cancel())
            }
            
            .onAppear{
                
                point = constants.editingPoint
                
                if point != nil {
                    title = point!.title
                    color = Color.getColorFromName(colorName: point!.color)
                    dateAdded = point!.dateAdded
                    coordinate = CLLocationCoordinate2D(latitude: point!.latitude, longitude: point!.longitude)
                } else {
                    title = "New point"
                    color = Color.orange
                    dateAdded = Date()
                    coordinate = constants.centerOfMap
                    print(#function, "point == nil")
                }
                
            }
            
        }
        
        
    }
    
    func delete() {
        
        moc.delete(point!)
        try? moc.save()
        
        constants.editingPoint = nil
        constants.needRedrawPointsOnMap = true
        
    }
    
    
    func save() {
        
        Point.addUpdatePoint(point: point,
                             moc: moc,
                             title: title,
                             color: color.description,
                             latitude: coordinate.latitude,
                             longitude: coordinate.longitude)
        
        constants.needRedrawPointsOnMap = true
        
    }
    
}

//struct PointEdit_Previews: PreviewProvider {
//    static var previews: some View {
//        PointEdit(point: nil)
//    }
//}
