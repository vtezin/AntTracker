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
                    .font(.title2)
                
                Spacer()
                
                VStack{
                    Text(currentTrack.durationString)
                        .fontWeight(.light)
                    if clManager.trackRecordingState == .paused {
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
                            Text("max")
                            Text(" \(currentTrack.maxSpeed.localeSpeedString)")
                        }
                        
                        HStack {
                            Text("avg")
                            Text(" \(currentTrack.averageSpeed.localeSpeedString)")
                        }

                    }
                    
                    Spacer()
                    
                    VStack {
                        HStack{
                            //Image(systemName: "arrow.up")
                            Text("altitude")
                            Text(String(format: "%.0f", currentTrack.lastAltitude) + " " + "m")
                        }
                        .padding(.bottom, 5)

                        VStack {
                            HStack{
                                Text("\(currentTrack.minAltitude)")
                                Image(systemName: "arrow.up.right")
                                Text("\(currentTrack.maxAltitude)")
                            }
                            Text("(\(currentTrack.maxAltitude - currentTrack.minAltitude)) " + "m")
                        }
    
                    }
                    
                }
                .modifier(LightText())
                .padding(.top)
                .transition(.move(edge: .bottom))
                
            }
            
        }
        .onTapGesture() {
            withAnimation{
                showFullInfo.toggle()
            }
        }
        .gesture(DragGesture(minimumDistance: 10, coordinateSpace: .local)
                            .onEnded({ value in
                                if value.translation.height < 0 {
                                    // up
                                    withAnimation{
                                        showFullInfo = false
                                    }
                                }
                            }))
        
        
    }
    
    
}

//struct TrackStatisticInfo_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackStatisticInfo()
//    }
//}
