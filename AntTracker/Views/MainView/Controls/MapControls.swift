//
//  MapControls.swift
//  AntTracker
//
//  Created by test on 22.05.2021.
//

import SwiftUI
import MapKit

extension MainView {
    
    func setMapSpan(delta: Double) {
        span = MKCoordinateSpan(latitudeDelta: delta,
                                longitudeDelta: delta)
        appVariables.needChangeMapView = true
    }
    
    var buttonZoomIn: some View {
        
        Button(action: {
            
        }) {
            Image(systemName: "plus")
                .modifier(MapButton())
                
                .onTapGesture() {
                    
                    let newDelta = max(span.latitudeDelta.rounded(toPlaces: 4)/zoomMultiplikator(), minSpan)
                    setMapSpan(delta: newDelta)
                    
                }
            
                .onLongPressGesture {
                    
                    makeVibration()
                    moveCenterMapToCurLocation()
                    setMapSpan(delta: minSpan * 2)
                    
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
                setMapSpan(delta: newDelta)
                
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
                    appVariables.needChangeMapView = true
                    
                } else {
                    
                    moveCenterMapToCurLocation()
                    
                    let newDelta = min(span.latitudeDelta * zoomMultiplikator() * 4, maxSpan)
                    setMapSpan(delta: newDelta)

                }
                
            }

        }
        .disabled(span.latitudeDelta == maxSpan)
        .foregroundColor(span.latitudeDelta == maxSpan ? .secondary : .primary)
        
    }
    
    func zoomMultiplikator() -> Double {
        
        if span.latitudeDelta < 0.05 {
            return 2
        } else {
            return 3
        }
        
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
    
    func altInfo() -> some View {
        
        HStack{
            Image(systemName: "arrow.up")
                .imageScale(.small)
            Text("\(Int(clManager.location.altitude)) m")
                .fontWeight(.light)
            Text("(+/-\(Int(clManager.location.verticalAccuracy)))")
                .modifier(SecondaryInfo())
            
        }
        .padding(10)
        .background(Color.systemBackground
                        .opacity(0.7)
                        .clipShape(RoundedRectangle(cornerRadius: 5)))
        .contextMenu {
            Button {
                mainViewShowCurrentAltitude = false
            } label: {
                Label("Hide", systemImage: "eye.slash")
            }
        }
        
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
        
        var fontSpeed: Font
        var paddingSpeed: CGFloat
        
        switch speed.speedKmHRounded() {
        case ..<5:
            fontSpeed = Font.headline
            paddingSpeed = 10
        case ..<15:
            fontSpeed = Font.title3
            paddingSpeed = 10
        default:
            fontSpeed = Font.title2
            paddingSpeed = 10
        }
        
        return
            
            HStack {
                
                //if speedOut > 0 {
                    Text(speedOut.localeSpeedString)
                        .fontWeight(.light)
                        .padding(paddingSpeed)
                        .background(Color.systemBackground
                                        .opacity(0.7)
                                        .clipShape(RoundedRectangle(cornerRadius: 5)))
                        .font(fontSpeed)
//                } else {
//                    Text("")
//                        .fontWeight(.light)
//                        .padding(paddingSpeed)
//                        .opacity(0)
//                }
                
            }
            .contextMenu {
                Button {
                    mainViewShowCurrentSpeed = false
                } label: {
                    Label("Hide", systemImage: "eye.slash")
                }
            }

    }

    
    
}
