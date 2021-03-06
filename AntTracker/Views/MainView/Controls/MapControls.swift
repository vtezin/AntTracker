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
        
        var deltaToSet: Double
        
        deltaToSet = min(delta, AppConstants.maxSpan)
        deltaToSet = max(deltaToSet, AppConstants.minSpan)
        
        span = MKCoordinateSpan(latitudeDelta: deltaToSet,
                                longitudeDelta: deltaToSet)
        appVariables.needChangeMapView = true
    }
    
    var buttonZoomIn: some View {
        
        Button(action: {
            
        }) {
            Image(systemName: "plus")
                .modifier(MapButton())
                
                .onTapGesture() {
                    setMapSpan(delta: span.latitudeDelta.rounded(toPlaces: 4)/zoomMultiplikator())
                }
            
                .onLongPressGesture {
                    makeVibration()
                    if span.latitudeDelta > AppConstants.curLocationSpan {
                        setMapSpan(delta: AppConstants.curLocationSpan)
                    }
                }
            
        }
        .disabled(span.latitudeDelta == AppConstants.minSpan)
        .foregroundColor(span.latitudeDelta == AppConstants.minSpan ? .secondary : .primary)
        
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
            .modifier(MapButton(disabled: span.latitudeDelta == AppConstants.maxSpan ))
            
            .onTapGesture() {
                setMapSpan(delta: span.latitudeDelta * zoomMultiplikator())
            }
        
            .onLongPressGesture {
                
                if currentTrack.trackCoreData != nil {
                    
                    makeVibration()
                    followCLbyMap = false
                    
                    let statistics = currentTrack.trackCoreData!.getStatistic(moc: moc)
                    let maxDist = max(statistics.distFromWestToEast, statistics.distFromNorthToSouth)
                    
                    center = statistics.centerPoint
                    
                    let region = MKCoordinateRegion(center: statistics.centerPoint,
                                                    latitudinalMeters: maxDist * 1.5,
                                                    longitudinalMeters: maxDist * 1.5)
                    
                    span = region.span
                    appVariables.needChangeMapView = true                    

                }
                
            }

        }
        .disabled(span.latitudeDelta == AppConstants.maxSpan)
        .foregroundColor(span.latitudeDelta == AppConstants.maxSpan ? .secondary : .primary)
        
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
            .onLongPressGesture {
                makeVibration()
                appVariables.darkMode = colorScheme == .light                
            }
        
    }
    
    
    var buttonCurLocation: some View {
        
        Image(systemName: followCLbyMap ? "location.fill" : "location")
            .modifier(MapButton())
            .foregroundColor(followCLbyMap ? .blue : .primary)
            .rotationEffect(.radians(2 * Double.pi * animationsCurLocationButtonRotatesCount))
            
            .onTapGesture() {
                
                //first tap - just move map to CL
                //second tap - if map center in CL than zoom in
                
                let needChangeSpan = followCLbyMap
                    && span.latitudeDelta > AppConstants.curLocationSpan
                
                moveCenterMapToCurLocation()
                
                if needChangeSpan {
                    setMapSpan(delta: AppConstants.curLocationSpan)
                }
                                
                withAnimation(.easeOut){
                    animationsCurLocationButtonRotatesCount += 1
                }
                
            }
        
            .onLongPressGesture {
                
                makeVibration()
                
                moveCenterMapToCurLocation()
                
                showPointsOnTheMap = true
                
                //fast adding new point
                lastQuickAddedPoint = Point.addUpdatePoint(point: nil,
                                     moc: moc,
                                     title: nil,
                                     info: nil,
                                     locationString: nil,
                                     color: nil,
                                     imageSymbol: nil,
                                     latitude: clManager.region.center.latitude,
                                     longitude: clManager.region.center.longitude,
                                     altitude: clManager.location.altitude,
                                     pointGroup: appVars.lastUsedPointGroup)
                
                if let lastQuickAddedPoint = lastQuickAddedPoint{
                    
                    getDescriptionByCoordinates(latitude: lastQuickAddedPoint.latitude,
                                                longitude: lastQuickAddedPoint.longitude,
                                                handler: fillLastQuickAddedPointLocationString)
                    //appVariables.selectedPoint = lastQuickAddedPoint
                    
                }
                
                appVariables.needRedrawPointsOnMap = true
                
            }
        
    }
    
    func startStopFollowCLForTimer() {
        
        followCLbyMap.toggle()
        
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
        
        switch speed.speedKmHRounded() {
        case ..<15:
            fontSpeed = Font.title2
        default:
            fontSpeed = Font.title2
        }
        
        return
            
            HStack {
                
                Text(speedOut.localeSpeedString)
                    .fontWeight(.light)
                    .padding(10)
                    .background(Color.systemBackground
                                    .opacity(0.7)
                                    .clipShape(RoundedRectangle(cornerRadius: 5)))
                    .font(fontSpeed)
                    .opacity(speedOut == 0 ? 0 : 1)
                    .transition(.move(edge: .trailing))
                
            }

    }

    
    
}
