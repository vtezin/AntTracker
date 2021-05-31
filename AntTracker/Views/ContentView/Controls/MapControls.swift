//
//  MapControls.swift
//  AntTracker
//
//  Created by test on 22.05.2021.
//

import SwiftUI
import MapKit

extension ContentView {
    
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
                    span = MKCoordinateSpan(latitudeDelta: minSpan * 2,
                                              longitudeDelta: minSpan * 2)
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
                span = MKCoordinateSpan(latitudeDelta: minSpan * 20,
                                          longitudeDelta: minSpan * 20)
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
    
}
