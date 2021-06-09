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
    
    var buttonTrackList: some View {
        
        Button(action: {
            withAnimation{
                activePage = .trackList
            }
            
        }) {
            Image(systemName: "tray.full")
                .modifier(ControlButton())
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
        
        let animationOn = clManager.trackRecording
        
        animatingProperties.lineWidth = animationOn ? 2 : 0
        animatingProperties.scaleEffect = animationOn ? 3 : 1
        animatingProperties.opacity = animationOn ? 0 : 1
    }
    
    
    var buttonTrackRecording: some View {
        
        Button(action: {
            
        }) {
            Image(systemName: "ant")
                .modifier(ControlButton())
                //.rotationEffect(.degrees(clManager.trackRecording ? 90 : 0))
                //r.foregroundColor(clManager.trackRecording ? Color.getColorFromName(colorName: currentTrackColor) : .primary)
                .overlay(
                    Circle()
                        .stroke(Color.getColorFromName(colorName: currentTrackColor), lineWidth: animatingProperties.lineWidth)
                        .scaleEffect(animatingProperties.scaleEffect)
                        .opacity(animatingProperties.opacity)
                        .animation(clManager.trackRecording ? pulseAnimation : Animation.default)
                )
            
                .onTapGesture {
                    withAnimation{
                        showRecordTrackControls.toggle()
                    }
                 }
                .onLongPressGesture {
                    if !clManager.trackRecording {
                        moveCenterMapToCurLocation()
                        withAnimation{
                            clManager.trackRecording = true
                        }
                        changeAnimatingProperties()
                    } else {
                        withAnimation{
                            clManager.trackRecording = false
                        }
                        animatingProperties.resetToDefaults()
                    }
                }
        }
        
        .onAppear{
            clManager.trackRecording.toggle()
            clManager.trackRecording.toggle()
            changeAnimatingProperties()
        }
        
        .onDisappear{
            animatingProperties.resetToDefaults()
        }
        
    }
    
    var buttonPointsManagement: some View {
        
        Button(action: {
            
        }) {
            Image(systemName: "mappin.and.ellipse")
                .modifier(ControlButton())
                .foregroundColor(showPointsManagment ? globalParameters.pointControlsColor : .primary)
                .onTapGesture {
                    withAnimation{
                        showPointsManagment.toggle()
                    }
                 }
                .onLongPressGesture {
                    
                    moveCenterMapToCurLocation()
                    
                    //fast adding new point
                    Point.addUpdatePoint(point: nil,
                                         moc: moc,
                                         title: nil,
                                         color: nil,
                                         latitude: clManager.region.center.latitude,
                                         longitude: clManager.region.center.longitude)
                    
                    constants.needRedrawPointsOnMap = true
                    
                }
            
        }

        
    }
    
}
