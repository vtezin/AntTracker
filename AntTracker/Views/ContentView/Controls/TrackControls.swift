//
//  TrackControls.swift
//  AntTracker
//
//  Created by test on 21.05.2021.
//

import SwiftUI

extension ContentView {
    
    var buttonTrackPlayPause: some View {
        
        Button(action: {
            //withAnimation{
                clManager.trackRecording.toggle()
            //}
        }) {
            Image(systemName: clManager.trackRecording ? "pause" : "play")
                .modifier(ControlButton())
        }
        
    }
    
    var buttonTrackReset: some View {
        
        Button(action: {
            showQuestionBeforeResetTrack = true
        }) {
            Image(systemName: "xmark")
                .modifier(ControlButton())
        }
        
    }
    
    var buttonTrackSave: some View {
        
        Button(action: {
            
            if currentTrack.trackCoreData == nil {
                //save new track
                sheetMode = .saveTrack
            } else {
                //update current track
                currentTrack.updateTrackInDB(moc: moc)
            }

            
        }) {
            Image(systemName: "tray.and.arrow.down")
                .modifier(ControlButton())
        }
        
        
    }
    
}
