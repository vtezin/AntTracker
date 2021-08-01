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
    
    @EnvironmentObject var appVariables: GlobalAppVars
    
    @AppStorage("lastUsedPointColor") var lastUsedPointColor: String = "orange"
    @AppStorage("lastUsedCLLatitude") var lastUsedCLLatitude: Double = 0
    @AppStorage("lastUsedCLLongitude") var lastUsedCLLongitude: Double = 0
    
    @State private var title: String = "New point"
    @State private var color: Color = Color.orange
    @State private var dateAdded: Date = Date()
    @State private var point: Point?
    @State private var coordinate = CLLocationCoordinate2D()
    @State private var altitude: Double  = 0
    
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
                        
                        
                            Text(coordinate.coordinateStrings[2])
                            if altitude != 0 {
                                HStack{
                                    Text("altitude")
                                    Text(altitude.string2s)
                                }
                                .modifier(SecondaryInfo())
                            }
                        
                        
                        Spacer()
                        
                        Button(action: {
                            
                            let pasteBoard = UIPasteboard.general
                            pasteBoard.string = coordinate.coordinateStrings[2]
                            
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
                    Button(action: {
                        kmlAPI.shareTextAsKMLFile(text: getTextForKMLFile(),
                                           filename: title)
                    }) {
                        Image(systemName: "square.and.arrow.up")
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
                
                ToolbarItem(placement: .bottomBar) {

                    Image(systemName: "trash")
                        .modifier(ControlButton())
                        .foregroundColor(.red)
                        .onTapGesture {
                            if point != nil {
                                showQuestionBeforeDelete = true
                            } else {
                                activePage = ContentView.pages.main
                            }
                        }
                }
                
                
            }
            
            .actionSheet(isPresented: $showQuestionBeforeDelete) {
                
                actionSheetForDelete(title: "Delete this point?") {
                    delete()
                    activePage = ContentView.pages.main
                } cancelAction: {
                    showQuestionBeforeDelete = false
                }

            }
            
            .onAppear{
                
                point = appVariables.editingPoint
                
                if point != nil {
                    title = point!.title
                    color = Color.getColorFromName(colorName: point!.color)
                    dateAdded = point!.dateAdded
                    coordinate = CLLocationCoordinate2D(latitude: point!.latitude, longitude: point!.longitude)
                    altitude = point!.altitude
                } else {
                    title = "New point"
                    color = Color.orange
                    dateAdded = Date()
                    coordinate = appVariables.centerOfMap
                }
                
            }
            
        }
        
        
    }
    
    func delete() {
        
        moc.delete(point!)
        try? moc.save()
        
        appVariables.editingPoint = nil
        appVariables.needRedrawPointsOnMap = true
        
    }
    
    
    func save() {
        
        Point.addUpdatePoint(point: point,
                             moc: moc,
                             title: title,
                             color: color.description,
                             latitude: coordinate.latitude,
                             longitude: coordinate.longitude,
                             altitude: altitude)
        
        appVariables.needRedrawPointsOnMap = true
        lastUsedPointColor = color.description
        
    }
    
    
    func getTextForKMLFile() -> String {
        
        var kmlText = ""
        kmlText += kmlAPI.headerFile(title: title)
        kmlText += kmlAPI.getPointTag(title: title,
                                      coordinate: coordinate,
                                      altitude: altitude)
        kmlText += kmlAPI.footerFile
        
        return kmlText
        
    }
    
}

//struct PointEdit_Previews: PreviewProvider {
//    static var previews: some View {
//        PointEdit(point: nil)
//    }
//}
