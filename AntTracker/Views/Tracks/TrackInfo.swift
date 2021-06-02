//
//  TrackInfo.swift
//  JustMap
//
//  Created by test on 05.04.2021.
//

import SwiftUI

struct TrackInfo: View {
    
    @StateObject var geoTrack: GeoTrack
    @State private var showFullInfo = false
    @EnvironmentObject var clManager: LocationManager
    
    var showingSavedTrack = true
    
    var body: some View {
        
        VStack{
            
            HStack{
                Text(geoTrack.totalDistanceString(maxAccuracy: 10))
                    .font(.title)
                
                Spacer()
                
                VStack{
                    if !showingSavedTrack
                        && clManager.trackRecording
                        && clManager.location.speed > 0 {
                        Text(clManager.location.speed.localeSpeedString)
                    }
                    Text(geoTrack.durationString)
                        .fontWeight(.light)
                }
                
                Spacer()
                Image(systemName: showFullInfo ? "chevron.up" : "chevron.down")
                
            }
            
            .onTapGesture() {
                //withAnimation{
                    showFullInfo.toggle()
                //}
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
                            Text(" \(geoTrack.averageSpeed.localeSpeedString)")
                                .fontWeight(.light)
                        }
                        
                        HStack {
                            Text("max")
                                .fontWeight(.light)
                            Text(" \(geoTrack.maxSpeed.localeSpeedString)")
                                .fontWeight(.light)
                        }

                    }
                    
                    Spacer()
                    
                    VStack {
                        HStack{
                            //Image(systemName: "arrow.up")
                            Text("altitude")
                            if !showingSavedTrack {
                                Text(String(format: "%.0f", clManager.location.altitude) + " " + "m")
                                    .fontWeight(.light)
                            }
                        }
                        .padding(.bottom, 5)

                        VStack {
                            HStack{
                                Text("\(geoTrack.minAltitude)")
                                    .fontWeight(.light)
                                Image(systemName: "arrow.up.right")
                                Text("\(geoTrack.maxAltitude)")
                                    .fontWeight(.light)
                            }
                            Text("(\(geoTrack.maxAltitude - geoTrack.minAltitude)) " + "m")
                                .fontWeight(.light)
                        }
    
                    }
                    
                    
                    
                }
                .padding(.top)
                
                if showingSavedTrack {
                    Divider()
                    VStack{
                        Text(periodDescription(start: geoTrack.startDate, end: geoTrack.finishDate))
                            .font(.caption)
                            .fontWeight(.thin)
                    }
                }
                
            }
            
        }
        
        
    }
}

//struct TrackInfo_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackInfo()
//    }
//}
