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
            appVariables.editingPoint = nil
            withAnimation{
                activePage = ContentView.pages.editPoint
            }
            showPointsManagment = false
        }) {
            VStack{
                Image(systemName: "star").modifier(ControlButton())
                Text("Add").buttonText()
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
    
    var buttonHideShowPoints: some View {
        
        Button(action: {
            showPointsOnTheMap.toggle()
            appVariables.needRedrawPointsOnMap = true
        }) {
            VStack{
                Image(systemName: showPointsOnTheMap ? "eye.slash" : "eye")
                    .modifier(ControlButton())
                Text(showPointsOnTheMap ? "Hide" : "Show").buttonText()
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
    
    
}
