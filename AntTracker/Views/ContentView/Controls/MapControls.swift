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
            let newDelta = max(span.latitudeDelta/zoomMultiplikator(), minSpan)
            span = MKCoordinateSpan(latitudeDelta: newDelta,
                                    longitudeDelta: newDelta)
            constants.needChangeMapView = true
            
        }) {
            Image(systemName: "plus")
                .modifier(MapButton())
        }
        //.disabled(span.latitudeDelta == minSpan)
        
    }
    
    var buttonZoomOut: some View {
        
        Button(action: {
            let newDelta = min(span.latitudeDelta * zoomMultiplikator(), maxSpan)
            
            span = MKCoordinateSpan(latitudeDelta: newDelta,
                                    longitudeDelta: newDelta)
            constants.needChangeMapView = true
            
        }) {
            
            ZStack {

                //for same sizes all buttons
                Image(systemName: "plus")
                    .opacity(0.0)

                Image(systemName: "minus")

            }
            .modifier(MapButton())

        }
        //.disabled(span.latitudeDelta == maxSpan)
        
    }
    
    var buttonCurLocation: some View {
        
        Image(systemName: "location")
            .modifier(MapButton())
            .overlay(
                Circle()
                    .stroke(Color.blue,
                            lineWidth: followCLforTimer ? 3 : 0)
            )
            .rotationEffect(.radians(2 * Double.pi * rotateCount))
            //.animation(.easeOut)
            
            .onTapGesture() {
                center = clManager.region.center
                constants.needChangeMapView = true
                withAnimation(.easeOut){
                    rotateCount += 1
                }
            }
        
            .onLongPressGesture {
                followCLforTimer.toggle()
                center = clManager.region.center
                constants.needChangeMapView = true
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
