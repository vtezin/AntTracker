//
//  TrackControlsView.swift
//  JustMap
//
//  Created by test on 11.03.2021.
//

import SwiftUI

enum TrackRecordingModes {
    
    case record
    case stop
    
}

struct TrackControlsView: View {
    
    @Binding var recordingMode: TrackRecordingModes
    @ObservedObject var locationManager: LocationManager
    
    var body: some View {
        
        VStack{
            
            HStack {
                Text("\(locationManager.currentTrack.totalDistance()) meters")
            }
            .padding(.bottom)
            
            HStack {
                
                Spacer()
                
                Image(systemName: locationManager.trackRecording ? "pause.circle" : "play.circle")
                    .font(.largeTitle)
                    .onTapGesture() {
                        locationManager.trackRecording.toggle()
                    }
                
                if locationManager.currentTrack.points.count > 0 && !locationManager.trackRecording {
                    
                    Image(systemName: "trash.circle")
                        .font(.largeTitle)
                        .onTapGesture() {
                            locationManager.trackRecording = false
                            locationManager.currentTrack.reset()
                            recordingMode = .stop
                        }
                    
                    Image(systemName: "square.and.arrow.down")
                        .font(.largeTitle)
                        .onTapGesture() {
                            
                        }
                    
                }
                
                Spacer()
                
            }
            //.padding(.horizontal)
            
        }
    
    }
}

//struct TrackControlsView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackControlsView(recordingMode: .constant(.stop), track: .constant(Track()))
//    }
//}
