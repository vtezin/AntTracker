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
        
        VStack {
            
            
            HStack {
                
                VStack{
                    
                    HStack {
                        
                        Image(systemName: "folder")
                            .font(Font.title.weight(.light))
                            //.imageScale(.medium)
                            .onTapGesture() {
                                
                            }
                        
                        Spacer()
                        
                        Text(locationManager.currentTrack.totalDistanceString(maxAccuracy: 10))
                            .font(.largeTitle)
                            .padding()
                        
                        Spacer()
                        
                        Image(systemName: locationManager.trackRecording ? "pause.circle" : "play.circle")
                            .font(Font.largeTitle.weight(.light))
                            //.imageScale(.large)
                            .onTapGesture() {
                                locationManager.trackRecording.toggle()
                            }
                        
                    }
                    
                    HStack {
                        Image(systemName: "hare")
                        Text("\(locationManager.currentTrack.lastSpeed().doubleKmH().string2s()) (max \(locationManager.currentTrack.maxSpeed().doubleKmH().string2s()) ) km/h")
                    }
                    .padding(.bottom)
                    
                }
                
            }
            
            if locationManager.currentTrack.points.count > 0 && !locationManager.trackRecording {
                
                HStack {
                    
                    Spacer()
                    
                    Image(systemName: "trash")
                        .font(Font.title.weight(.light))
                        .onTapGesture() {
                            locationManager.trackRecording = false
                            locationManager.currentTrack.reset()
                            recordingMode = .stop
                        }
                    
                    Spacer()
                    
                    Image(systemName: "square.and.arrow.down")
                        .font(Font.title.weight(.light))
                        .onTapGesture() {
                            
                        }
                    
                    Spacer()
                    
                    
                }
                
            }
            
        }
            
    }
}

//struct TrackControlsView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackControlsView(recordingMode: .constant(.stop), track: .constant(Track()))
//    }
//}
