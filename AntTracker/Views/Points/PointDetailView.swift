//
//  PointDetailView.swift
//  AntTracker
//
//  Created by test on 13.05.2021.
//

import SwiftUI
import CoreLocation

struct PointDetailView: View {
    
    @Binding var activePage: ContentView.pages
    @Binding var pointListRefreshID: UUID?
    
    let point: Point?
    var centerOfMap: CLLocationCoordinate2D?
    
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var appVariables: GlobalAppVars
    
    @AppStorage("lastUsedPointColor") var lastUsedPointColor: String = "orange"
    @AppStorage("lastUsedCLLatitude") var lastUsedCLLatitude: Double = 0
    @AppStorage("lastUsedCLLongitude") var lastUsedCLLongitude: Double = 0
    @AppStorage("lastUsedCLAltitude") var lastUsedCLAltitude: Int = 0
    
    @State private var title: String
    @State private var info: String
    @State private var imageSymbol: String
    @State private var color: Color
    @State private var dateAdded: Date
    @State private var coordinate: CLLocationCoordinate2D
    @State private var altitude: Int
    
    @State private var showQuestionBeforeDelete = false
    @State private var showColorSelector = false
    
    //selecting group
    @State private var group: PointGroup?
    @State private var showGroupSelection = false
    
    enum FirstResponders: Int {
        case title
    }
    @State var firstResponder: FirstResponders?
    
    init(point: Point?,
         centerOfMap: CLLocationCoordinate2D?,
         activePage: Binding<ContentView.pages>,
         pointListRefreshID: Binding<UUID?>) {
        
        self.point = point
        self._activePage = activePage
        self._pointListRefreshID = pointListRefreshID
        
        if let point = point {
            //init by existing point
            
            _title = State(initialValue: point.title)
            _info = State(initialValue: point.wrappedInfo)
            _color = State(initialValue: Color.getColorFromName(colorName: point.wrappedColor))
            _imageSymbol = State(initialValue: point.wrappedImageSymbol)
            _dateAdded = State(initialValue: point.dateAdded)
            _coordinate = State(initialValue: CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude))
            _altitude = State(initialValue: Int(point.altitude))
            _group = State(initialValue: point.pointGroup)
            
        } else {
            //adding new point
            
            _firstResponder = State(initialValue: .title)
            _title = State(initialValue: Date().dateString())
            _info = State(initialValue: "")
            _imageSymbol = State(initialValue: SFSymbolsAPI.pointDefaultImageSymbol)
            _color = State(initialValue: globalParameters.defaultColor)
            _dateAdded = State(initialValue: Date())
            _altitude = State(initialValue: 0)
            
            _coordinate = State(initialValue: centerOfMap!)
            let distanceToCL = CLLocation(latitude: lastUsedCLLatitude, longitude: lastUsedCLLongitude).distance(from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
            if distanceToCL <= 30 {
                _altitude = State(initialValue:lastUsedCLAltitude)
            }
            
        }

    }
    
    func setAdressToInfo(adressString: String) {
        if info.isEmpty {
            info = adressString
        }
    }
    
    var body: some View {
        
        NavigationView{
            
            Form{
                
                Section() {
                    
                        HStack{
                            
                            if group == nil {
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
                            }
                            
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
                    
                    HStack{
                        PointGroupRawView(group: group)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showGroupSelection = true
                    }
                        
                }
                
                Section(header: Text("Description")) {
                    
                    ZStack {
                        TextEditor(text: $info)
                        Text(info).opacity(0).padding(.all, 8)
                    }
                    
                    if info.isEmpty {
                        
                        VStack(alignment: .leading){
                            
                            Button(action: {
                                
                                getDescriptionByCoordinates(latitude: coordinate.latitude, longitude: coordinate.longitude, handler: setAdressToInfo)
                                
                            }) {
                                
                                Text("Fill in with address")
                            }
                            
                            Text("Internet access required")
                                .modifier(SecondaryInfo())
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
                appVariables.selectedPoint = nil
                activePage = ContentView.pages.main
            }) {
                Text("Cancel")
            },
            trailing: Button(action: {
                save()
                appVariables.selectedPoint = nil
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
            
            .sheet(isPresented: $showGroupSelection) {
                PointGroupSelectionView(selectedGroup: $group)
                    .environment(\.managedObjectContext, moc)
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
                
                if point == nil {
                    getDescriptionByCoordinates(latitude: coordinate.latitude, longitude: coordinate.longitude, handler: setAdressToInfo)
                }
                
                
            }

            
        }
        
        
    }
    
    func delete() {
        
        moc.delete(point!)
        try? moc.save()
        
        appVariables.selectedPoint = nil
        appVariables.needRedrawPointsOnMap = true
        
    }
    
    
    func save() {
        
        Point.addUpdatePoint(point: point,
                             moc: moc,
                             title: title,
                             info: info,
                             color: color.description,
                             imageSymbol: imageSymbol,
                             latitude: coordinate.latitude,
                             longitude: coordinate.longitude,
                             altitude: Double(altitude),
                             pointGroup: group)
        
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
