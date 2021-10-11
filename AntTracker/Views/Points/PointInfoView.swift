//
//  PointInfoView.swift
//  AntTracker
//
//  Created by test on 15.09.2021.
//

import SwiftUI
import MapKit

struct PointInfoView: View {
    
    let point: Point
    
    @EnvironmentObject var appVariables: AppVariables
    @EnvironmentObject var clManager: LocationManager
    @Environment(\.managedObjectContext) var moc
    @AppStorage("mainViewShowCurrentAlt") var mainViewShowCurrentAltitude: Bool = false
    
    @Binding var actionSheetMode: MainView.ActionSheetModes
    @Binding var showActionSheet: Bool
    
    var body: some View {
        
        VStack{
            
            if !point.wrappedInfo.isEmpty {
                Text(point.wrappedInfo).padding(3)
            }
            
            if !point.wrappedLocationString.isEmpty {
                Text(point.wrappedLocationString).padding(3)
                    .contextMenu {
                        Button {
                            let pasteBoard = UIPasteboard.general
                            pasteBoard.string = point.wrappedLocationString
                        } label: {
                            Label("Copy", systemImage: "arrow.right.doc.on.clipboard")
                        }
                    }
            }
            
            HStack{

                Menu{
                    
                    if !point.wrappedLocationString.isEmpty {
                        
                        Button{
                            point.shareLocationString()
                        } label: {
                            Label("Address", systemImage: "square.and.arrow.up")
                        }
                        
                    }
                    
                    Button{
                        point.shareCoordinatesString()
                    } label: {
                        Label("Coordinates", systemImage: "square.and.arrow.up")
                    }
                    
                    Button{
                        point.shareAsKMLFile()
                    } label: {
                        Label("KML file", systemImage: "square.and.arrow.up")
                    }
                    
                    
                } label: {
                    VStack{
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                HStack{
                    Image(systemName: "location.fill")
                    Text(localeDistanceString(distanceMeters: clManager.location.distance(from: CLLocation(latitude: point.latitude, longitude: point.longitude))))
                }


                if mainViewShowCurrentAltitude {

                    Spacer()

                    //altitude

                    let altitudeDelta = point.wrappedAltitude - clManager.location.roundedAltitude

                    HStack{
                        Image(systemName: "arrow.up")
                        Text("\(point.wrappedAltitude) m")
                        if altitudeDelta != 0 {
                            Image(systemName: altitudeDelta > 0 ? "arrow.up.right" : "arrow.down.right")
                            Text("\(altitudeDelta) m")
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .onTapGesture {
                        actionSheetMode = .deleteSelectedPoint
                        showActionSheet = true
                    }

            }
            .font(.body)
            .padding(5)
            
        }
        .modifier(SecondaryInfo())
        
    }
    
    func deletePoint()  {
        
        func deleteSelectedPoint() {
            
            if appVariables.selectedPoint == point {
                appVariables.selectedPoint = nil
            }
            
            Point.deletePoint(point: point, moc: moc)
            appVariables.needRedrawPointsOnMap = true
            
        }
        
    }
    
}

//struct PointInfoView_Previews: PreviewProvider {
//    static var previews: some View {
//        PointInfoView()
//    }
//}
