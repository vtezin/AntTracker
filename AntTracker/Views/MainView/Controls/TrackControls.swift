//
//  TrackControls.swift
//  AntTracker
//
//  Created by test on 21.05.2021.
//

import SwiftUI

extension MainView {
    
    var buttonTrackPlayPause: some View {
        
        Button(action: {
            withAnimation{
                clManager.trackRecording.toggle()
                if clManager.trackRecording {
                    moveCenterMapToCurLocation()
                }
            }
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
                activePage = ContentView.pages.saveCurrentTrack
            } else {
                //update current track
                currentTrack.trackCoreData!.fillByCurrentTrackData(moc: moc)
                try? moc.save()
            }
            dateOfSavingCurrentTrack = Date()

            
        }) {
            Image(systemName: "tray.and.arrow.down")
                .modifier(ControlButton())
        }
        
        
    }
    
}
