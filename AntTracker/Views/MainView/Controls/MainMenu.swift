//
//  MainMenu.swift
//  AntTracker
//
//  Created by test on 21.05.2021.
//

import SwiftUI

extension MainView {
    
    var buttonBackToMainControls: some View {
        
        Button(action: {
            withAnimation {
                showRecordTrackControls = false
                showPointsManagment = false
            }
            
        }) {
            Image(systemName: "arrow.backward")
                .modifier(ControlButton())
        }
        
    }
    
    var buttonAppSettings: some View {
        
        Button(action: {
            withAnimation{
                activePage = .settings
            }
        }) {
            Image(systemName: "gearshape")
                .modifier(ControlButton())
        }
        
    }
    
    var buttonOptions: some View {
        
        Menu{
            
            Button(action: {
                withAnimation{
                    activePage = .settings
                }
            }) {
                Label("Settings", systemImage: "gear")
            }
            
            Divider()
            
            Button(action: {
                showPointsOnTheMap.toggle()
                appVariables.needRedrawPointsOnMap = true
            }) {
                Label(showPointsOnTheMap ? "Hide points" : "Show points",
                    systemImage: "")
                .labelStyle(TitleOnlyLabelStyle())
            }
            
            Button(action: {
                mapType = mapType == .standard ? .hybrid : .standard
                lastUsedMapType = mapType == .standard ? "standart" : "hybrid"
                appVariables.needChangeMapView = true
            }) {
                Label(mapType == .standard ? "Switch to satellite" : "Switch to standard map",
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
    
    
    var buttonTrackList: some View {
        
        Button(action: {
            withAnimation{
                activePage = .trackList
            }
        }) {
            
            VStack{
                Image(systemName: "tray.2")
                    .modifier(ControlButton())
                Text("Tracks").buttonText()
            }
        }
        
    }
    
    class AntAnimatingProperties: ObservableObject {
        
        @Published var lineWidth: CGFloat = 0
        @Published var scaleEffect: CGFloat = 1
        @Published var opacity: Double = 1
        
        func resetToDefaults() {
            lineWidth = 0
            scaleEffect = 1
            opacity = 1
        }
    }
    
    func changeAnimatingProperties() {
        
        animateAnt = clManager.trackRecording
        
        animatingProperties.lineWidth = animateAnt ? 2 : 0
        animatingProperties.scaleEffect = animateAnt ? 3 : 1
        animatingProperties.opacity = animateAnt ? 0 : 1
    }
    
    
    var buttonTrackRecording: some View {
        
        Button(action: {}) {
            
            VStack{
                
                Image(systemName: "ant")
                    .modifier(ControlButton())
                    .foregroundColor(clManager.trackRecording ? Color.getColorFromName(colorName: currentTrackColor) : .primary)
                    .overlay(
                        Circle()
                            .stroke(Color.getColorFromName(colorName: currentTrackColor), lineWidth: animatingProperties.lineWidth)
                            .scaleEffect(animatingProperties.scaleEffect)
                            .opacity(animatingProperties.opacity)
                            .animation(clManager.trackRecording ? pulseAnimation : Animation.default)
                    )
                
                Text("Record").buttonText()
                
            }
            
            .onTapGesture {
                withAnimation{
                    showRecordTrackControls.toggle()
                }
            }
            .onLongPressGesture {
                
                startOrStopTrackRecording()
                
                if clManager.trackRecording {
                    changeAnimatingProperties()
                } else {
                    animatingProperties.resetToDefaults()
                    if currentTrack.points.count > 0 {
                        showRecordTrackControls = true
                    }
                }
                
            }
        }
        
        .onAppear{
            animateAnt.toggle()
            animateAnt.toggle()
            changeAnimatingProperties()
        }
        
        .onDisappear{
            animatingProperties.resetToDefaults()
        }
        
    }
    
    var buttonPointsManagement: some View {
            
            Button(action: {}) {
                
                VStack {
                    Image(systemName: "mappin.and.ellipse")
                        .modifier(ControlButton())
                        .foregroundColor(showPointsManagment ? globalParameters.pointControlsColor : .primary)
                    Text("Points").buttonText()
                }
                
                    .onTapGesture {
                        withAnimation{                        
                            if followCL {
                                startStopFollowCLForTimer()
                            }
                            showPointsManagment.toggle()
                        }
                    }
                    .onLongPressGesture {
                        
                        moveCenterMapToCurLocation()
                        
                        showPointsOnTheMap = true
                        
                        //fast adding new point
                        Point.addUpdatePoint(point: nil,
                                             moc: moc,
                                             title: nil,
                                             color: nil,
                                             latitude: clManager.region.center.latitude,
                                             longitude: clManager.region.center.longitude, altitude: clManager.location.altitude)
                        
                        appVariables.needRedrawPointsOnMap = true
                        
                    }
                
            }
        
    }
    
}
