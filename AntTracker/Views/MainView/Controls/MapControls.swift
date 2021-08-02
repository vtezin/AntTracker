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
                    
                    let newDelta = max(span.latitudeDelta.rounded(toPlaces: 4)/zoomMultiplikator(), minSpan)
                    
                    span = MKCoordinateSpan(latitudeDelta: newDelta,
                                            longitudeDelta: newDelta)
                    appVariables.needChangeMapView = true
                    
                }
            
                .onLongPressGesture {
                    makeVibration()
                    moveCenterMapToCurLocation()
                    //let newDelta = max(span.latitudeDelta/(zoomMultiplikator() * 2), minSpan)
                    let newDelta = minSpan * 2
                    span = MKCoordinateSpan(latitudeDelta: newDelta,
                                            longitudeDelta: newDelta)
                    appVariables.needChangeMapView = true
                }
            
        }
        .disabled(span.latitudeDelta == minSpan)
        .foregroundColor(span.latitudeDelta == minSpan ? .secondary : .primary)
        
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
                
                makeVibration()
                followCLforTimer = false
                
                if currentTrack.trackCoreData != nil {
                    
                    let statistics = currentTrack.trackCoreData!.getStatistic(moc: moc)
                    let maxDist = max(statistics.distFromWestToEast, statistics.distFromNorthToSouth)
                    
                    center = statistics.centerPoint
                    
                    let region = MKCoordinateRegion(center: statistics.centerPoint,
                                                    latitudinalMeters: maxDist * 1.5,
                                                    longitudinalMeters: maxDist * 1.5)
                    
                    span = region.span
                    
                } else {
                    
                    moveCenterMapToCurLocation()
                    
                    let newDelta = min(span.latitudeDelta * zoomMultiplikator() * 4, maxSpan)
                    
                    span = MKCoordinateSpan(latitudeDelta: newDelta,
                                            longitudeDelta: newDelta)
                }
                
                appVariables.needChangeMapView = true
            }

        }
        .disabled(span.latitudeDelta == maxSpan)
        .foregroundColor(span.latitudeDelta == maxSpan ? .secondary : .primary)
        
    }
    
    var buttonMapType: some View {
        
        Image(mapType == .standard ? "satelite": "map")
            .frame(width: 50, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .clipShape(Circle())
            .clipped()
            .opacity(0.8)
            .onTapGesture() {
                mapType = mapType == .standard ? .hybrid : .standard
                lastUsedMapType = mapType == .standard ? "standart" : "hybrid"
                appVariables.needChangeMapView = true
            }
            .padding()
        
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
                makeVibration()
                startStopFollowCLForTimer()
                moveCenterMapToCurLocation()
            }
        
    }
    
    func startStopFollowCLForTimer() {
        
        followCLforTimer.toggle()
        
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
                
                if gpsAccuracy > 10 {
                    Text("gps +/- \(gpsAccuracy) m")
                        .fontWeight(.light)
                        .padding(5)
                        .background(colorAccuracy.opacity(0.7).clipShape(RoundedRectangle(cornerRadius: 5)))
                } else {
                    Text("")
                    .fontWeight(.light)
                    .padding(5)
                    .opacity(0)
                }
                
            }
            .font(.subheadline)
            
    }
    
    
    func speedInfo() -> some View {
        
        let speed = clManager.location.speed
        //let gpsAccuracy = Int(clManager.location.horizontalAccuracy)
        
        var speedOut: Double
        
        if speed < 0.5 {
            speedOut = 0
        } else {
            speedOut = speed
        }
        
        var fontSpeed = Font.headline
        var paddingSpeed: CGFloat = 5
        
        switch speed.speedKmHRounded() {
        case ..<10:
            fontSpeed = Font.headline
            paddingSpeed = 5
        case 10..<50:
            fontSpeed = Font.title3
            paddingSpeed = 7
        default:
            fontSpeed = Font.title2
            paddingSpeed = 10
        }
        
        return
            
            HStack {
                
                if speedOut > 0 {
                    Text(speedOut.localeSpeedString)
                        .fontWeight(.light)
                        .padding(paddingSpeed)
                        .background(Color.systemBackground
                                        .opacity(0.7)
                                        .clipShape(RoundedRectangle(cornerRadius: 5)))
                        .font(fontSpeed)
                } else {
                    Text("")
                        .fontWeight(.light)
                        .padding(paddingSpeed)
                        .opacity(0)
                }
                
            }
    }

    
    
}
