//
//  PointGroupView.swift
//  AntTracker
//
//  Created by test on 06.09.2021.
//

import SwiftUI

struct PointGroupView: View {
    
    @Binding var activePage: ContentView.pages
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appVariables: AppVariables
    
    let group: PointGroup
    var points: FetchRequest<Point>
    
    @State private var showingGroupDetailView = false
    @Binding var pointListRefreshID: UUID //for force refreshing
    
    init(group: PointGroup, activePage: Binding<ContentView.pages>, pointListRefreshID: Binding<UUID>) {
        
        self.group = group
        points = FetchRequest(entity: Point.entity(),
                              sortDescriptors: [NSSortDescriptor(keyPath: \Point.dateAdded, ascending: false)],
                      predicate: NSPredicate(format: "pointGroup == %@", group))
        _activePage = activePage
        
        _pointListRefreshID = pointListRefreshID
        
    }
        
    var body: some View {
        
        List{
            
            ForEach(points.wrappedValue, id: \.id) { point in

                Button(action: {
                    
                    appVariables.mapSettingsForAppear = (latitude: point.latitude,
                                                         longitude: point.longitude,
                                                         span: AppConstants.curLocationSpan)
                    
                    activePage = ContentView.pages.main
                    
                }) {
                    PointRawView(point: point)
                }

            }
            
        }
        .id(pointListRefreshID)
        
        .sheet(isPresented: $showingGroupDetailView) {
            PointGroupDetailView(group: group, pointListRefreshID: $pointListRefreshID)
        }
        .navigationBarTitle(group.title, displayMode: .inline)
        .navigationBarItems(
            trailing: Button(action: {
                showingGroupDetailView = true
            }) {
                Image(systemName: "info.circle")
                    .modifier(NavigationButton())
            })
        
    }

    
}

//struct PointGroupView_Previews: PreviewProvider {
//    static var previews: some View {
//        PointGroupView()
//    }
//}
