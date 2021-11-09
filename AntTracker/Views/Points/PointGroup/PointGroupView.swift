//
//  PointGroupView.swift
//  AntTracker
//
//  Created by test on 06.09.2021.
//

import SwiftUI

struct PointGroupView: View {
    
    @AppStorage("showPointsOnTheMap") var showPointsOnTheMap = true
    
    @Binding var activePage: ContentView.pages
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appVariables: AppVariables
    
    let group: PointGroup
    var points: FetchRequest<Point>
    
    @State private var showOnMap = false
    @State private var showingGroupDetailView = false
    @Binding var pointListRefreshID: UUID //for force refreshing
    
    @State private var showQuestionBeforeDelete = false
    
    init(group: PointGroup, activePage: Binding<ContentView.pages>, pointListRefreshID: Binding<UUID>) {
        
        self.group = group
        points = FetchRequest(entity: Point.entity(),
                              sortDescriptors: [NSSortDescriptor(keyPath: \Point.dateAdded, ascending: false)],
                      predicate: NSPredicate(format: "pointGroup == %@", group))
        
        _activePage = activePage
        _pointListRefreshID = pointListRefreshID
        _showOnMap = State(initialValue: group.showOnMap)
        
    }
        
    var body: some View {
        
        List{
            
            ForEach(points.wrappedValue, id: \.id) { point in

                Button(action: {
                    
                    if !showOnMap {
                        
                        showOnMap = true
                        PointGroup.toggleShowOnMap(group: group, moc: moc, showOnMap: showOnMap)
                        
                    }
                    
                    appVariables.selectedPoint = point
                    appVariables.mapSettingsForAppear = (latitude: point.latitude,
                                                         longitude: point.longitude,
                                                         span: AppConstants.curLocationSpan)
                    
                    showPointsOnTheMap = true
                    activePage = ContentView.pages.main
                    
                    
                }) {
                    PointRawView(point: point, showPointImage: false)
                }

            }
            
        }
        .id(pointListRefreshID)
        
        .sheet(isPresented: $showingGroupDetailView) {
            PointGroupDetailView(group: group, pointListRefreshID: $pointListRefreshID)
        }
        
        .actionSheet(isPresented: $showQuestionBeforeDelete) {
            actionSheetForDelete(title: "Delete this group? (all points are saved and become points outside the groups)") {
                delete()
            } cancelAction: {
                showQuestionBeforeDelete = false
            }
        }
        
        .navigationBarTitle(group.wrappedTitle, displayMode: .inline)
        .navigationBarItems(
            trailing: Button(action: {
                showingGroupDetailView = true
            }) {
                Image(systemName: "info.circle")
                    .modifier(NavigationButton())
            })
        
        .toolbar {
            
            ToolbarItem(placement: .principal) {
                HStack{
                    group.imageView
                    Text(group.wrappedTitle)
                }
            }
            
            ToolbarItem(placement: .bottomBar) {
                
                Image(systemName: "square.and.arrow.up")
                    .modifier(ControlButton())
                    .onTapGesture {
                        kmlAPI.shareTextAsKMLFile(text: group.getTextForKMLFile(),
                                                  filename: group.wrappedTitle)
                    }
                
            }
            
            ToolbarItem(placement: .bottomBar) {
                Spacer()
            }
            
            ToolbarItem(placement: .bottomBar) {
                Toggle(isOn: $showOnMap.animation()) {
                    HStack{
                        Image(systemName: "eye")
                        Text("on the map")
                    }
                }
                .onChange(of: showOnMap) { value in
                    PointGroup.toggleShowOnMap(group: group, moc: moc, showOnMap: value)
                    appVariables.needRedrawPointsOnMap = true
                    pointListRefreshID = UUID()
                }
            }
            
            ToolbarItem(placement: .bottomBar) {
                Spacer()
            }
            
            ToolbarItem(placement: .bottomBar) {
                
                Image(systemName: "trash")
                    .modifier(ControlButton())
                    .foregroundColor(.red)
                    .onTapGesture {
                        showQuestionBeforeDelete = true
                    }
                
            }
            
            
        }
        
    }

    func delete() {
        
        PointGroup.deleteGroup(group: group, moc: moc)
        
        appVariables.needRedrawPointsOnMap = true
        presentationMode.wrappedValue.dismiss()
    
    }
    
}

//struct PointGroupView_Previews: PreviewProvider {
//    static var previews: some View {
//        PointGroupView()
//    }
//}
