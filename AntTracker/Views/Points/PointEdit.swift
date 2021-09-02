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
    @AppStorage("lastUsedCLAltitude") var lastUsedCLAltitude: Int = 0
    
    @State private var title: String = ""
    @State private var imageSymbol = SFSymbolsAPI.pointDefaultImageSymbol
    @State private var color: Color = Color.orange
    @State private var dateAdded: Date = Date()
    @State private var point: Point?
    @State private var coordinate = CLLocationCoordinate2D()
    @State private var altitude: Int = 0
    
    @State private var showQuestionBeforeDelete = false
    @State private var showColorSelector = false
    
    enum FirstResponders: Int {
        case title
    }
    @State var firstResponder: FirstResponders?
    
    var body: some View {
        
        NavigationView{
            
            Form{
                
                Section() {
                    
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
                
                
                Section(header: Text("Coordinate")) {
                    
                    HStack{
                        
                        Text(coordinate.coordinateStrings[2])
                        
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
                
                if altitude != 0 {
                    
                    Section(header: Text("Altitude")) {
                        
                        let altitudeDelta = altitude - lastUsedCLAltitude
                        
                        HStack{
                            Text("\(altitude) m")
                            Spacer()
                            if altitudeDelta != 0 {
                                Image(systemName: altitudeDelta > 0 ? "arrow.up.right" : "arrow.down.right")
                                    .foregroundColor(.secondary)
                                Text("\(altitudeDelta) m")
                                    .foregroundColor(.secondary)
                            }
                        }
                    
                    }
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
                    imageSymbol = point!.wrappedImageSymbol
                    dateAdded = point!.dateAdded
                    coordinate = CLLocationCoordinate2D(latitude: point!.latitude, longitude: point!.longitude)
                    altitude = Int(point!.altitude)
                    
                } else {
                    
                    coordinate = appVariables.centerOfMap
                    firstResponder = .title
                    let distanceToCL = CLLocation(latitude: lastUsedCLLatitude, longitude: lastUsedCLLongitude).distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
                    if distanceToCL <= 30 {
                        altitude = lastUsedCLAltitude
                    }
                    
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
                             imageSymbol: imageSymbol,
                             latitude: coordinate.latitude,
                             longitude: coordinate.longitude,
                             altitude: Double(altitude))
        
        appVariables.needRedrawPointsOnMap = true
        lastUsedPointColor = color.description
        
    }
    
    
    func getTextForKMLFile() -> String {
        
        var kmlText = ""
        kmlText += kmlAPI.headerFile(title: title)
        kmlText += kmlAPI.getPointTag(title: title,
                                      coordinate: coordinate,
                                      altitude: Double(altitude))
        kmlText += kmlAPI.footerFile
        
        return kmlText
        
    }
    
}

//struct PointEdit_Previews: PreviewProvider {
//    static var previews: some View {
//        PointEdit(point: nil)
//    }
//}
