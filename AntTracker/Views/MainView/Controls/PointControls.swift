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
            }
            HStack{
                buttonBackToMainControls
                Spacer()
                buttonAddPoint
                Spacer()
                buttonPointList
                Spacer()
                buttonPointsMore
            }
        }
        .transition(.move(edge: .bottom))
        
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
            
            Button(action: {
                showPointsOnTheMap.toggle()
                appVariables.needRedrawPointsOnMap = true
            }) {
                Label(showPointsOnTheMap ? "Hide points" : "Show points",
                    systemImage: "")
                .labelStyle(TitleOnlyLabelStyle())
            }
            
        } label: {
            
            VStack{
                Image(systemName: "ellipsis.circle")
                    .modifier(ControlButton())
                Text("More").buttonText()
            }
        }
        
    }
    
    var selectetPointInfo: some View {
        
        let selectedPoint = appVariables.selectedPoint!
        
        return VStack{
            
            HStack{
                
                Spacer()
                
                VStack{
                    HStack{
                        Image(systemName: selectedPoint.wrappedImageSymbol)
                            .foregroundColor(.white)
                            .imageScale(.medium)
                            .padding(7)
                            .background(Color.getColorFromName(colorName: selectedPoint.wrappedColor))
                            .clipShape(Circle())
                        Text(selectedPoint.wrappedTitle)
                            .foregroundColor(Color.getColorFromName(colorName: selectedPoint.wrappedColor))
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
        .onTapGesture {
            withAnimation {
                activePage = .editPoint
            }
        }
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
            
            Button{
                kmlAPI.shareTextAsKMLFile(
                    text: selectedPoint.textForKMLFile(),
                                   filename: selectedPoint.wrappedTitle)
            } label: {
                Label("KML file", systemImage: "square.and.arrow.up")
            }
            
            Button{
                let coordinateString = selectedPoint.coordinate.coordinateStrings[2]
                
                // Show the share-view
                let av = UIActivityViewController(activityItems: [coordinateString], applicationActivities: nil)
                        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
            } label: {
                Label("Coordinates", systemImage: "square.and.arrow.up")
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
