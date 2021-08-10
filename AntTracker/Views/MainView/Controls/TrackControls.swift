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
        
        buttons.append(.default(Text(clManager.trackRecording ?
                                        "Pause" :
                                        currentTrack.points.count > 0 ? "Continue recording"
                                        : "Start recording")) {
            
            startOrStopTrackRecording()
            
        })
        
        
        if currentTrack.trackCoreData != nil {
            
            buttons.append(.default(Text("Finish track")) {
                
                if clManager.trackRecording {
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
            showCurrentTrackActions = false
        })
        
        return buttons
        
    }
    
    func startOrStopTrackRecording() {
        
        withAnimation{
            if clManager.trackRecording {
                clManager.trackRecording = false
            } else {
                currentTrack.prepareForStartRecording(moc: moc)
                moveCenterMapToCurLocation()
                setMapSpan(delta: minSpan * 3)
                clManager.trackRecording = true
            }
        }
        
        if clManager.trackRecording {
            changeAnimatingProperties()
        } else {
            animatingProperties.resetToDefaults()
        }
        
    }
    
    func resetTrack() {
        
        clManager.trackRecording = false
        
        if let trackCD = currentTrack.trackCoreData {
            Track.deleteTrack(track: trackCD, moc: moc)
        }
        
        animatingProperties.resetToDefaults()
        
    }
    
}
