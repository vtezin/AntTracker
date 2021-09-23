//
//  TrackControls.swift
//  AntTracker
//
//  Created by test on 21.05.2021.
//

import SwiftUI

extension MainView {
    
    func currentTrackActions() -> [ActionSheet.Button] {
        
        var buttons = [ActionSheet.Button]()
        
        buttons.append(.default(Text(clManager.trackRecordingState == .recording ?
                                        "Pause" :
                                        currentTrack.points.count > 0 ? "Continue recording"
                                        : "Start recording")) {
            
            startOrStopTrackRecording()
            
        })
        
        
        if currentTrack.trackCoreData != nil {
            
            buttons.append(.default(Text("Finish track")) {
                
                if clManager.trackRecordingState == .recording {
                    //stop recording
                    startOrStopTrackRecording()
                }
                if currentTrack.points.count > 0 {
                    //open view for saving track
                    activePage = ContentView.pages.completeTrack
                } else {
                    //track is clean
                    //just reset track
                    resetTrack()
                }
                
            })
            
        }
        
       
        if currentTrack.points.count > 0 {
            
            buttons.append(.destructive(Text("Reset")) {
                showQuestionBeforeResetTrack = true
            })
            
            animatingProperties.resetToDefaults()
            
        }
        
        buttons.append(.cancel(Text("Cancel")) {
            showActionSheet = false
        })
        
        return buttons
        
    }
    
    func startOrStopTrackRecording() {
        
        withAnimation{
            if clManager.trackRecordingState == .recording {
                clManager.trackRecordingState = .paused
            } else {
                startTrackRecording()
            }
        }
        
        if clManager.trackRecordingState == .recording {
            changeAnimatingProperties()
        } else {
            animatingProperties.resetToDefaults()
        }
        
    }
    
    func startTrackRecording() {
        
        currentTrack.prepareForStartRecording(moc: moc)
        moveCenterMapToCurLocation()
        setMapSpan(delta: AppConstants.curLocationSpan)
        
        clManager.trackRecordingState = .recording
                
    }
    
    func resetTrack() {
        
        clManager.trackRecordingState = .none
        
        if let trackCD = currentTrack.trackCoreData {
            Track.deleteTrack(track: trackCD, moc: moc)
        }
        
        animatingProperties.resetToDefaults()
        
    }
    
}
