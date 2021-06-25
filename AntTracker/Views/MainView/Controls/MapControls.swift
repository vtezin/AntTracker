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
                    appVariables.needChangeMapView = true
                }
            
                .onLongPressGesture {
                    moveCenterMapToCurLocation()
                    //let newDelta = max(span.latitudeDelta/(zoomMultiplikator() * 2), minSpan)
                    let newDelta = minSpan * 2
                    span = MKCoordinateSpan(latitudeDelta: newDelta,
                                            longitudeDelta: newDelta)
                    appVariables.needChangeMapView = true
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
                appVariables.needChangeMapView = true
            }
        
            .onLongPressGesture {
                let newDelta = min(span.latitudeDelta * zoomMultiplikator() * 2, maxSpan)
                
                span = MKCoordinateSpan(latitudeDelta: newDelta,
                                        longitudeDelta: newDelta)
                appVariables.needChangeMapView = true
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
                startStopFollowCLForTimer()
                moveCenterMapToCurLocation()
            }
        
    }
    
    func startStopFollowCLForTimer() {
        
        followCLforTimer.toggle()
        setDisableAutolockScreen()
        
    }
    
    func setDisableAutolockScreen() {
        if UserDefaults.standard.bool(forKey: "disableAutolockScreenWhenTrackRecording") {
            UIApplication.shared.isIdleTimerDisabled = followCLforTimer || clManager.trackRecording
        }
    }
    
    func gpsAccuracyAndSpeedInfo() -> some View {
        
        let gpsAccuracy = Int(clManager.location.horizontalAccuracy)
        let speed = clManager.location.speed
        
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
                
                if gpsAccuracy > 10 {
                    Text("gps +/- \(gpsAccuracy) m")
                        .fontWeight(.light)
                        .padding(5)
                        .background(colorAccuracy.opacity(0.7).clipShape(RoundedRectangle(cornerRadius: 5)))
                } else if speed > 0.5 {
                    Text(speed.localeSpeedString)
                        .fontWeight(.light)
                        .padding(5)
                        .background(colorAccuracy.opacity(0.7).clipShape(RoundedRectangle(cornerRadius: 5)))
                } else {
                    Text("")
                    .fontWeight(.light)
                    .padding(5)
                }
                
            }
            .font(.subheadline)
            
    }
    
}
