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
                            //.padding(.bottom)
                    }
                    Text(geoTrack.durationString)
                        .fontWeight(.thin)
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
                        Divider()
                        
                        HStack {
                            Text("avg")
                                .fontWeight(.thin)
                            Text(" \(geoTrack.averageSpeed.localeSpeedString)")
                                .fontWeight(.thin)
                        }
                        
                        HStack {
                            Text("max")
                                .fontWeight(.thin)
                            Text(" \(geoTrack.maxSpeed.localeSpeedString)")
                                .fontWeight(.thin)
                        }

                    }
                    
                    Spacer()
                    
                    VStack {
                        HStack{
                            Image(systemName: "arrow.up")
                            if !showingSavedTrack {
                                Text(String(format: "%.0f", clManager.location.altitude) + " " + "m")
                                    .fontWeight(.thin)
                            }
                        }
                        Divider()
                        VStack {
                            HStack{
                                Text("\(geoTrack.minAltitude)")
                                    .fontWeight(.thin)
                                Image(systemName: "arrow.up.right")
                                Text("\(geoTrack.maxAltitude)")
                                    .fontWeight(.thin)
                            }
                            Text("(\(geoTrack.maxAltitude - geoTrack.minAltitude)) " + "m")
                                .fontWeight(.thin)
                        }
    
                    }
                    
                    
                    
                }
                .padding(.top)
                
                if showingSavedTrack {
                    Divider()
                    VStack{
                        Text(periodDescription(start: geoTrack.startDate, end: geoTrack.finishDate))
                    }
                    .modifier(SecondaryInfo())
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
