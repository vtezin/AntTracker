//
//  MainMenu.swift
//  AntTracker
//
//  Created by test on 21.05.2021.
//

import SwiftUI

extension ContentView {
    
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
        
        NavigationLink(destination: AppSettings(isNavigationBarHidden: $isNavigationBarHidden)) {
            Image(systemName: "gearshape")
                .modifier(ControlButton())
        }
        
    }
    
    var buttonTrackList: some View {
        
        NavigationLink(destination: TrackListView(isNavigationBarHidden: $isNavigationBarHidden)) {
            
            Image(systemName: "tray.full")
                .modifier(ControlButton())
            
        }
        
    }
    
    var buttonTrackRecording: some View {
        
        Button(action: {
            withAnimation {
                showRecordTrackControls.toggle()
            }
            
        }) {
            Image(systemName: "ant")
                .modifier(ControlButton())
                .rotationEffect(.degrees(clManager.trackRecording ? 90 : 0))
                //.scaleEffect(clManager.trackRecording ? 1.2 : 1)
                //.animation(.easeInOut)
                .overlay(
                    Circle()
                        .stroke(Color.systemBackground,
                                lineWidth: showRecordTrackControls ? 4 : 0)
                )
        }
        
    }
    
    var buttonPointsManagement: some View {
        
        Button(action: {
            withAnimation {
                showPointsManagment.toggle()
            }
            
        }) {
            Image(systemName: "mappin.and.ellipse")
                .modifier(ControlButton())
                .foregroundColor(showPointsManagment ? globalParameters.pointControlsColor : .primary)
            
        }
        
    }
    
}
