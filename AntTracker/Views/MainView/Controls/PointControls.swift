//
//  PointControls.swift
//  AntTracker
//
//  Created by test on 22.05.2021.
//

import SwiftUI
import MapKit

extension MainView {
    
    var pointControlsPane: some View {
        
        VStack{
            
            if showGoToCoordinates {
                barGoToCoordinates
                    .padding(.init(top: 3, leading: 0, bottom: 3, trailing: 0))
                    .transition(.move(edge: .bottom))
            } else {
                                
                HStack{
                    Image(systemName: "location.fill")
                    Text(selectedPositionDistanceFromCL)
                }
                .modifier(SecondaryInfo())
                .padding(.bottom)
                
                HStack{
                    
                    Text(selectedPositionAddress)
                        .modifier(SecondaryInfo())
                        .padding(.bottom)
                        .contextMenu {
                            Button {
                                let pasteBoard = UIPasteboard.general
                                pasteBoard.string = selectedPositionAddress
                            } label: {
                                Label("Copy", systemImage: "arrow.right.doc.on.clipboard")
                            }
                        }
                    
                }
                
            }
            
            
            HStack{
                buttonBackToMainControls
                Spacer()
                buttonAddPoint
                Spacer()
                buttonPointShare
                Spacer()
                buttonGoToCoordinates
            }
        }
        .transition(.move(edge: .bottom))
        .gesture(DragGesture(minimumDistance: 10, coordinateSpace: .local)
                    .onEnded({ value in
                        if value.translation.height > 0 {
                            // down
                            withAnimation{
                                showPointsManagment = false
                            }
                        }
                    }))
        
    }
    
    var buttonPointShare: some View {
        
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
            
            Button(action: {
                
                let av = UIActivityViewController(activityItems: [selectedPositionAddress],
                                                  applicationActivities: nil)
                UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true,
                                                                                completion: nil)
                
            }) {
                Label("Address", systemImage: "square.and.arrow.up")
                    //.labelStyle(TitleOnlyLabelStyle())
            }
            
        } label: {
            
            VStack{
                Image(systemName: "square.and.arrow.up")
                    .modifier(ControlButton())
                Text("Share").buttonText()
            }
        }
        
    }
    
    
    var buttonAddPoint: some View {
        
        Button(action: {
            showPointsOnTheMap = true
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
                    
                    center = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
                    appVariables.needChangeMapView = true
                    
                    showInvalidFormatGoToCoordinates = false
                    showGoToCoordinates = false
                    
                }
                .disabled(coordinatesForImportPoint.isEmpty)
                
                Button(action: {
                    withAnimation {
                        showGoToCoordinates = false
                    }
                }) {
                    Image(systemName: "xmark.circle").modifier(ControlButton())
                        .foregroundColor(.secondary)
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
    
    var selectetPointInfo: some View {
        
        let selectedPoint = appVariables.selectedPoint!
        
        return VStack{
            
            HStack{
                
                Button(action: {
                    withAnimation {
                        activePage = .editPoint
                    }
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.secondary)
                }
                .padding(.leading)
                
                Spacer()
                
                VStack{
                    HStack{
                        selectedPoint.imageView
                        Text(selectedPoint.wrappedTitle)
                            .foregroundColor(Color.getColorFromName(colorName: selectedPoint.wrappedColor))
                    }
                    .onTapGesture {
                        withAnimation {
                            activePage = .editPoint
                        }
                    }
                    
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation{
                        appVariables.selectedPoint = nil
                    }
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.secondary)
                }
                .padding(.trailing)
                
            }
            
            HStack {
                PointInfoView(point: selectedPoint)
            }
            
        }
        .padding(10)
        .background(Color.systemBackground
                        .clipShape(RoundedRectangle(cornerRadius: 5)))

        .gesture(DragGesture(minimumDistance: 10, coordinateSpace: .local)
                    .onEnded({ value in
                        if value.translation.height > 0 {
                            // down
                            withAnimation{
                                appVariables.selectedPoint = nil
                            }
                        }
                    }))
        .contextMenu{
            
            if !selectedPoint.wrappedLocationString.isEmpty {
                
                Button{
                    let sharedString = selectedPoint.wrappedLocationString
                    
                    // Show the share-view
                    let av = UIActivityViewController(activityItems: [sharedString], applicationActivities: nil)
                    UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
                } label: {
                    Label("Address", systemImage: "square.and.arrow.up")
                }
                
            }
            
            Button{
                let sharedString = selectedPoint.coordinate.coordinateStrings[2]
                
                // Show the share-view
                let av = UIActivityViewController(activityItems: [sharedString], applicationActivities: nil)
                        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
            } label: {
                Label("Coordinates", systemImage: "square.and.arrow.up")
            }
            
            Button{
                kmlAPI.shareTextAsKMLFile(
                    text: selectedPoint.textForKMLFile(),
                                   filename: selectedPoint.wrappedTitle)
            } label: {
                Label("KML file", systemImage: "square.and.arrow.up")
            }
            
            
            Divider()
            
            Button{
                actionSheetMode = .deleteSelectedPoint
                showActionSheet = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
        }
        
    }
    
    func deleteSelectedPoint() {
        
        if let pointForDelete = appVariables.selectedPoint {
            appVariables.selectedPoint = nil
            Point.deletePoint(point: pointForDelete, moc: moc)
            appVariables.needRedrawPointsOnMap = true
        }
        
    }
    
}
