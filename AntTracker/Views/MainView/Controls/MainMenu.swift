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
            VStack{
                Image(systemName: "gearshape")
                    .modifier(ControlButton())
                Text("Settings").buttonText()
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
        
        animateAnt = clManager.trackRecordingState == .recording
        
        animatingProperties.lineWidth = animateAnt ? 2 : 0
        animatingProperties.scaleEffect = animateAnt ? 3 : 1
        animatingProperties.opacity = animateAnt ? 0 : 1
    }
    
    
    var buttonTrackRecording: some View {
        
        Button(action: {}) {
            
            VStack{
                
                if showCurrentTrackActions {
                    Image(systemName: "ant")
                        .modifier(ControlButton())
                } else {
                    
                    Image(systemName: "ant")
                        .modifier(ControlButton())
                        .foregroundColor(clManager.trackRecordingState == .recording ? Color.getColorFromName(colorName: currentTrackColor) : .primary)
                        .overlay(
                            Circle()
                                .stroke(Color.getColorFromName(colorName: currentTrackColor), lineWidth: animatingProperties.lineWidth)
                                .scaleEffect(animatingProperties.scaleEffect)
                                .opacity(animatingProperties.opacity)
                                .animation(clManager.trackRecordingState == .recording  ? pulseAnimation : Animation.default)
                        )
                    
                }
                
                Text("Record").buttonText()
                
            }
            
            .onTapGesture {
                showCurrentTrackActions = true
            }
            .onLongPressGesture {
                makeVibration()
                startOrStopTrackRecording()
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
                            
                        }
                        
                        
                        appVariables.needRedrawPointsOnMap = true
                        
                    }
                
            }
        
    }
    
    func fillLastQuickAddedPointLocationString(adressString: String) {
        
        if let lastQuickAddedPoint = lastQuickAddedPoint {
            lastQuickAddedPoint.setLocationString(moc: moc,
                                                  locationString: adressString)
        }
        
    }
 
    
}
