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
            //withAnimation {
                showRecordTrackControls = false
                showPointsManagment = false
            //}
            
        }) {
            Image(systemName: "arrow.backward")
                .modifier(ControlButton())
        }
        
    }
    
    var buttonAppSettings: some View {
        
        Button(action: {
            activePage = .settings
            
        }) {
            Image(systemName: "gearshape")
                .modifier(ControlButton())
        }
        
    }
    
    var buttonTrackList: some View {
        
        Button(action: {
            activePage = .list
            
        }) {
            Image(systemName: "tray.full")
                .modifier(ControlButton())
        }
        
    }
    
    var buttonTrackRecording: some View {
        
        Button(action: {
            
        }) {
            Image(systemName: "ant")
                .modifier(ControlButton())
                .rotationEffect(.degrees(clManager.trackRecording ? 90 : 0))
                //.scaleEffect(clManager.trackRecording ? 1.2 : 1)
                //.animation(.easeInOut)
                .foregroundColor(clManager.trackRecording ? Color.getColorFromName(colorName: currentTrackColor) : .primary)
                .overlay(
                    Circle()
                        .stroke(Color.systemBackground,
                                lineWidth: showRecordTrackControls ? 4 : 0)
                )
            
                .onTapGesture {
                    showRecordTrackControls.toggle()
                 }
                .onLongPressGesture {
                    if !clManager.trackRecording {
                        moveCenterMapToCurLocation()
                        showRecordTrackControls = true
                        clManager.trackRecording = true
                    }
                }
            
            
        }
        
    }
    
    var buttonPointsManagement: some View {
        
        Button(action: {
            
        }) {
            Image(systemName: "mappin.and.ellipse")
                .modifier(ControlButton())
                .foregroundColor(showPointsManagment ? globalParameters.pointControlsColor : .primary)
                .onTapGesture {
                    showPointsManagment.toggle()
                 }
                .onLongPressGesture {
                    
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
