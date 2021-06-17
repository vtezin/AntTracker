//
//  TrackStatisticInfo.swift
//  AntTracker
//
//  Created by test on 03.06.2021.
//

import SwiftUI

struct CurrentTrackInfo: View {
    
    @EnvironmentObject var currentTrack: CurrentTrack
    @EnvironmentObject var clManager: LocationManager
    
    @State private var showFullInfo = false
    
    var body: some View {
        
        VStack{
            
            HStack{
                Text(localeDistanceString(distanceMeters: currentTrack.totalDistanceMeters))
                    .font(.title)
                
                Spacer()
                
                VStack{
                    Text(currentTrack.durationString)
                        .fontWeight(.light)
                    if !clManager.trackRecording {
                        Text("(pause)")
                            .foregroundColor(.secondary)
                            .fontWeight(.light)
                    }
                }
                
                Spacer()
                Image(systemName: showFullInfo ? "chevron.up" : "chevron.down")
                
            }
            
            if showFullInfo {
                
                HStack{
                    
                    VStack {
                        HStack{
                            Image(systemName: "hare")
                        }
                        .padding(.bottom, 5)
                        
                        HStack {
                            Text("avg")
                                .fontWeight(.light)
                            Text(" \(currentTrack.averageSpeed.localeSpeedString)")
                                .fontWeight(.light)
                        }
                        
                        HStack {
                            Text("max")
                                .fontWeight(.light)
                            Text(" \(currentTrack.maxSpeed.localeSpeedString)")
                                .fontWeight(.light)
                        }

                    }
                    
                    Spacer()
                    
                    VStack {
                        HStack{
                            //Image(systemName: "arrow.up")
                            Text("altitude")

                                Text(String(format: "%.0f", currentTrack.lastAltitude) + " " + "m")
                                    .fontWeight(.light)
                            
                        }
                        .padding(.bottom, 5)

                        VStack {
                            HStack{
                                Text("\(currentTrack.minAltitude)")
                                    .fontWeight(.light)
                                Image(systemName: "arrow.up.right")
                                Text("\(currentTrack.maxAltitude)")
                                    .fontWeight(.light)
                            }
                            Text("(\(currentTrack.maxAltitude - currentTrack.minAltitude)) " + "m")
                                .fontWeight(.light)
                        }
    
                    }
                    
                    
                    
                }
                .padding(.top)
                .transition(.move(edge: .bottom))
                
            }
            
        }
        .onTapGesture() {
            withAnimation{
                showFullInfo.toggle()
            }
        }
        
        
    }
    
    
}

//struct TrackStatisticInfo_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackStatisticInfo()
//    }
//}
