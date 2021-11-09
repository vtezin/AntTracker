//
//  PointListView.swift
//  AntTracker
//
//  Created by test on 06.09.2021.
//

import SwiftUI

struct PointListView: View {
    
    @Binding var activePage: ContentView.pages
    
    @AppStorage("showPointsOnTheMap") var showPointsOnTheMap = true
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var moc
    @EnvironmentObject var appVariables: AppVariables
    
    @FetchRequest(entity: Point.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \Point.dateAdded, ascending: false)],
                  predicate: NSPredicate(format: "pointGroup == nil")) var points: FetchedResults<Point>
    
    @FetchRequest(entity: PointGroup.entity(),
                  sortDescriptors: [NSSortDescriptor(keyPath: \PointGroup.dateOfLastChange, ascending: false)]) var groups: FetchedResults<PointGroup>
    
    @State private var indexSetToDeleteGroup: IndexSet?
    @State private var showQuestionBeforeDeleteGroup = false
    
    //adding new group
    @State private var showingAddGroupView = false
    
    @State private var pointListRefreshID: UUID = UUID() //for force refreshing
    
    init(activePage: Binding<ContentView.pages>) {
        self._activePage = activePage
    }
    
    var body: some View {
        
        NavigationView {
            
            List{
                
                //groups
                ForEach(groups, id: \.id) { group in

                    NavigationLink(destination:
                                    PointGroupView(group: group,
                                                   activePage: $activePage,
                                                   pointListRefreshID: $pointListRefreshID)) {

                        HStack{
                            PointGroupRawView(group: group)
                            Spacer()
                            Text("\(group.pointsArray.count)")
                                .modifier(SecondaryInfo())
                        }
                        
                    }

                }
                
                .onDelete(perform: { indexSet in
                    showQuestionBeforeDeleteGroup = true
                    indexSetToDeleteGroup = indexSet
                })
                                
                .actionSheet(isPresented: $showQuestionBeforeDeleteGroup) {
                    actionSheetForDelete(title: "Delete this group? (all points are saved and become points outside the groups)") {
                        deleteGroup(at: indexSetToDeleteGroup)
                    } cancelAction: {
                        showQuestionBeforeDeleteGroup = false
                    }
                }
                
                
                ForEach(points, id: \.id) { point in
                    
                    Button(action: {
                        appVariables.selectedPoint = point
                        appVariables.mapSettingsForAppear = (latitude: point.latitude,
                                                             longitude: point.longitude,
                                                             span: AppConstants.curLocationSpan)
                        showPointsOnTheMap = true
                        activePage = ContentView.pages.main
                    }) {
                        PointRawView(point: point, showPointImage: true)
                    }
                    
                }
                
            }
            .id(pointListRefreshID)
            .sheet(isPresented: $showingAddGroupView) {
                PointGroupDetailView(group: nil, pointListRefreshID: $pointListRefreshID)
            }
                        
            .navigationBarTitle("Points", displayMode: .inline)
            .navigationViewStyle(StackNavigationViewStyle())
            
            .navigationBarItems(
                leading: Button(action: {
                    withAnimation{
                        activePage = .main
                    }
                }) {
                    HStack{
                        Image(systemName: "chevron.backward")
                        Text("Map")
                    }
                }
                ,
                trailing: Button(action: {
                    showingAddGroupView = true
                }) {
                    Image(systemName: "folder.badge.plus")
                        .modifier(NavigationButton())
                }
            )
            
            .toolbar {
                
                ToolbarItem(placement: .bottomBar) {
                    
                    Toggle(isOn: $showPointsOnTheMap.animation()) {
                        HStack{
                            Image(systemName: "eye")
                            Text("on the map")
                        }
                    }
                    
                }
                
                
            }
            
        }
        .navigationViewStyle(StackNavigationViewStyle())
        
    }
}

extension PointListView {
    
    private func deleteGroup(at offsets: IndexSet?) {
        
        for offset in offsets! {
            // find this group in our fetch request
            let group = groups[offset]
            
            PointGroup.deleteGroup(group: group, moc: moc)
            
        }
        
    }
    
}

//struct PointListView_Previews: PreviewProvider {
//    static var previews: some View {
//        PointListView()
//    }
//}
