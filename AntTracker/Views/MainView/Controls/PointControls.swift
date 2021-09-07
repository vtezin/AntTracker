//
//  PointControls.swift
//  AntTracker
//
//  Created by test on 22.05.2021.
//

import SwiftUI
import MapKit

extension MainView {
    
    var buttonAddPoint: some View {
        
        Button(action: {
            showPointsOnTheMap = true
            appVariables.editingPoint = nil
            withAnimation{
                activePage = ContentView.pages.editPoint
            }
            showPointsManagment = false
        }) {
            VStack{
                Image(systemName: "star").modifier(ControlButton())
                Text("Save").buttonText()
            }
        }
        
    }
    
    var buttonGoToCoordinates: some View {
        
        Button(action: {
            withAnimation {
                showGoToCoordinates.toggle()
            }
        }) {
            VStack{
                Image(systemName: "arrow.down.to.line").modifier(ControlButton())
                Text("Go to").buttonText()
            }
        }
        
    }
    
    var barGoToCoordinates: some View {
        
        VStack {
            
            if showInvalidFormatGoToCoordinates {
                Text("invalid coordinate string format")
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding()
            }
            
            HStack{
                
                Button(action: {
                    if let stringFromClipboard = UIPasteboard.general.string{
                        coordinatesForImportPoint = stringFromClipboard
                    }
                }) {
                        Image(systemName: "arrow.right.doc.on.clipboard")
                }
                
                TextField("enter the coordinates", text: $coordinatesForImportPoint)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numbersAndPunctuation)
                    .font(.caption)
                    .modifier(ClearButton(text: $coordinatesForImportPoint))
                
                Button("Go to") {
                    
                    var coordinates = coordinatesForImportPoint.components(separatedBy: ", ")
                    if coordinates.count != 2 {
                        coordinates = coordinatesForImportPoint.components(separatedBy: " ")
                    }
                    
                    if coordinates.count != 2 {
                        showInvalidFormatGoToCoordinates = true
                        return
                    }
                    
                    let latitude = Double(coordinates[0])
                    let longitude = Double(coordinates[1])
                    
                    if latitude == nil || longitude == nil {
                        showInvalidFormatGoToCoordinates = true
                        return
                    }
                    
//                    Point.addUpdatePoint(point: nil,
//                                         moc: moc,
//                                         title: Date().dateString(),
//                                         color: lastUsedPointColor,
//                                         latitude: latitude!,
//                                         longitude: longitude!)
//
//                    appVariables.needRedrawPointsOnMap = true
                    
                    center = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
                    appVariables.needChangeMapView = true
                    
                    showInvalidFormatGoToCoordinates = false
                    showGoToCoordinates = false
                    //showPointsManagment = false
                }
            }
            
            VStack(alignment: .leading){
                Text("latitude and longitude separated by space or comma")
                Text("for example 55.52969, 38.909821")
            }
                .font(.caption)
                .foregroundColor(.secondary)
            
        }
        
        
    }
    
    var buttonSharePosition: some View {
        
        Menu{
            
            Button(action: {
                
                let coordinate = appVariables.centerOfMap
                let title = "Position from AntTracker"
                
                var kmlText = ""
                kmlText += kmlAPI.headerFile(title: title)
                kmlText += kmlAPI.getPointTag(title: title,
                                              coordinate: coordinate, altitude: nil)
                kmlText += kmlAPI.footerFile
                
                kmlAPI.shareTextAsKMLFile(text: kmlText,
                                   filename: title)
                
            }) {
                Label("KML file", systemImage: "")
                    .labelStyle(TitleOnlyLabelStyle())
            }
            
            Button(action: {
                
                let av = UIActivityViewController(activityItems: [appVariables.centerOfMap.coordinateStrings[2]],
                                                  applicationActivities: nil)
                UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true,
                                                                                completion: nil)
                
            }) {
                Label("Coordinates", systemImage: "")
                    .labelStyle(TitleOnlyLabelStyle())
            }
            
        } label: {
            
            VStack{
                Image(systemName: "square.and.arrow.up")
                    .modifier(ControlButton())
                Text("Share").buttonText()
            }
        }
        
        
        
    }
    
    var buttonPointList: some View {
        
        Button(action: {
            withAnimation{
                activePage = .pointList
            }
        }) {
            VStack{
                Image(systemName: "tray.2").modifier(ControlButton())
                Text("Points").buttonText()
            }
        }
        
    }
    
    var buttonPointsMore: some View {
        
        Menu{
            
            Button(action: {
                
                let coordinate = appVariables.centerOfMap
                let title = "Position from AntTracker"
                
                var kmlText = ""
                kmlText += kmlAPI.headerFile(title: title)
                kmlText += kmlAPI.getPointTag(title: title,
                                              coordinate: coordinate, altitude: nil)
                kmlText += kmlAPI.footerFile
                
                kmlAPI.shareTextAsKMLFile(text: kmlText,
                                   filename: title)
                
            }) {
                Label("KML file", systemImage: "square.and.arrow.up")
                    //.labelStyle(TitleOnlyLabelStyle())
            }
            
            Button(action: {
                
                let av = UIActivityViewController(activityItems: [appVariables.centerOfMap.coordinateStrings[2]],
                                                  applicationActivities: nil)
                UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true,
                                                                                completion: nil)
                
            }) {
                Label("Coordinates", systemImage: "square.and.arrow.up")
                    //.labelStyle(TitleOnlyLabelStyle())
            }
            
            Divider()
            
            Button(action: {
                withAnimation {
                    showGoToCoordinates.toggle()
                }
            }) {
                VStack{
                    Image(systemName: "arrow.down.to.line").modifier(ControlButton())
                    Text("Go to").buttonText()
                }
            }
            
        } label: {
            
            VStack{
                Image(systemName: "ellipsis.circle")
                    .modifier(ControlButton())
                Text("More").buttonText()
            }
        }
        
    }
    
    
}
