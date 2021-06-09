//
//  MapControls.swift
//  AntTracker
//
//  Created by test on 22.05.2021.
//

import SwiftUI
import MapKit

extension MainView {
    
    var buttonZoomIn: some View {
        
        Button(action: {
            
        }) {
            Image(systemName: "plus")
                .modifier(MapButton())
                
                .onTapGesture() {
                    let newDelta = max(span.latitudeDelta/zoomMultiplikator(), minSpan)
                    span = MKCoordinateSpan(latitudeDelta: newDelta,
                                            longitudeDelta: newDelta)
                    constants.needChangeMapView = true
                }
            
                .onLongPressGesture {
                    let newDelta = max(span.latitudeDelta/(zoomMultiplikator() * 2), minSpan)
                    span = MKCoordinateSpan(latitudeDelta: newDelta,
                                            longitudeDelta: newDelta)
                    constants.needChangeMapView = true
                }
            
        }
        //.disabled(span.latitudeDelta == minSpan)
        
    }
    
    var buttonZoomOut: some View {
        
        Button(action: {
            
        }) {
            
            ZStack {

                //for same sizes all buttons
                Image(systemName: "plus")
                    .opacity(0.0)

                Image(systemName: "minus")

            }
            .modifier(MapButton())
            
            .onTapGesture() {
                let newDelta = min(span.latitudeDelta * zoomMultiplikator(), maxSpan)
                
                span = MKCoordinateSpan(latitudeDelta: newDelta,
                                        longitudeDelta: newDelta)
                constants.needChangeMapView = true
            }
        
            .onLongPressGesture {
                let newDelta = min(span.latitudeDelta * zoomMultiplikator() * 2, maxSpan)
                
                span = MKCoordinateSpan(latitudeDelta: newDelta,
                                        longitudeDelta: newDelta)
                constants.needChangeMapView = true
            }

        }
        //.disabled(span.latitudeDelta == maxSpan)
        
    }
    
    var buttonCurLocation: some View {
        
        Image(systemName: "location")
            .modifier(MapButton())
            .overlay(
                Circle()
                    .stroke(Color.getColorFromName(colorName: currentTrackColor),
                            lineWidth: followCLforTimer ? 3 : 0)
            )
            .rotationEffect(.radians(2 * Double.pi * rotateCount))
            //.animation(.easeOut)
            
            .onTapGesture() {
                moveCenterMapToCurLocation()
                withAnimation(.easeOut){
                    rotateCount += 1
                }
            }
        
            .onLongPressGesture {
                followCLforTimer.toggle()
                moveCenterMapToCurLocation()
            }
        
    }
    
    var buttonMapType: some View {
        
        Button(action: {
            mapType = mapType == .standard ? .hybrid : .standard
            lastUsedMapType = mapType == .standard ? "standart" : "hybrid"
            constants.needChangeMapView = true
        }) {
            Image(systemName: mapType == .standard ? "globe" : "map")
        }
        .modifier(MapButton())
        
    }
    
    func gpsAccuracyInfo() -> some View {
        
        let gpsAccuracy = Int(clManager.location.horizontalAccuracy)
        
        var colorAccuracy = Color.red
        
        switch gpsAccuracy {
        case ..<20:
            colorAccuracy = Color.systemBackground
        case 20..<100:
            colorAccuracy = Color.yellow
        default:
            colorAccuracy = Color.red
        }
        
        return
            
            HStack {
                
                //Spacer()
                
                if gpsAccuracy > 10 {
                    Text("gps +/- \(gpsAccuracy) m")
                }
                
                //Spacer()
                
            }
            .font(.caption)
            .foregroundColor(.primary)
            .padding(5)
            .background(colorAccuracy.opacity(0.7).clipShape(RoundedRectangle(cornerRadius: 5)))

    }
    
    
}
