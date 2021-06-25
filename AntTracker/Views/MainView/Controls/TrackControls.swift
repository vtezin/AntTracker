//
//  TrackControls.swift
//  AntTracker
//
//  Created by test on 21.05.2021.
//

import SwiftUI

extension MainView {
    
    func startOrStopTrackRecording() {
        withAnimation{
            if clManager.trackRecording {
                clManager.trackRecording = false
            } else {
                currentTrack.prepareForStartRecording(moc: moc)
                moveCenterMapToCurLocation()
                clManager.trackRecording = true
            }
        }
        setDisableAutolockScreen()
    }
    
    var buttonTrackPlayPause: some View {
        
        Button(action: {
            startOrStopTrackRecording()
        }) {
            VStack{
                Image(systemName: clManager.trackRecording ? "pause" : "play")
                    .modifier(ControlButton())
                Text(clManager.trackRecording ? "Pause" : "Record").buttonText()
            }
        }
        
    }
    
    var buttonTrackReset: some View {
        
        Button(action: {
            showQuestionBeforeResetTrack = true
        }) {
            VStack{
                Image(systemName: "xmark")
                    .modifier(ControlButton())
                Text("Reset").buttonText()
            }
        }
        
    }
    
    var buttonTrackSave: some View {
                
        Button(action: {
            if clManager.trackRecording {
                //stop recording
                startOrStopTrackRecording()
            }
            activePage = ContentView.pages.completeTrack
        }) {
            VStack{
                Image(systemName: "stop")
                    .modifier(ControlButton())
                Text("Stop").buttonText()
            }
        }
        
    }
    
}
