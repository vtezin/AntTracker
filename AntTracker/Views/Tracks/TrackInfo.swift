//
//  TrackInfo.swift
//  JustMap
//
//  Created by test on 05.04.2021.
//

import SwiftUI

struct TrackInfo: View {
    
    let track: Track
    @State private var showFullInfo = false
    @EnvironmentObject var clManager: LocationManager
    
    var body: some View {
        
        VStack{
            
            HStack{
                Text(localeDistanceString(distanceMeters: track.totalDistanceMeters))
                    .font(.title)
                
                Spacer()
                
                VStack{
                    Text(track.durationString)
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
                            Text(" \(track.averageSpeed.localeSpeedString)")
                                .fontWeight(.light)
                        }
                        
                        HStack {
                            Text("max")
                                .fontWeight(.light)
                            Text(" \(track.maxSpeed.localeSpeedString)")
                                .fontWeight(.light)
                        }

                    }
                    
                    Spacer()
                    
                    VStack {
                        HStack{
                            //Image(systemName: "arrow.up")
                            Text("altitude")
                        }
                        .padding(.bottom, 5)

                        VStack {
                            HStack{
                                Text("\(track.minAltitude)")
                                    .fontWeight(.light)
                                Image(systemName: "arrow.up.right")
                                Text("\(track.maxAltitude)")
                                    .fontWeight(.light)
                            }
                            Text("(\(track.maxAltitude - track.minAltitude)) " + "m")
                                .fontWeight(.light)
                        }
    
                    }
                    
                    
                    
                }
                .padding(.top)
                
                    Divider()
                    VStack{
                        Text(periodDescription(start: track.startDate, end: track.finishDate))
                            .font(.caption)
                            .fontWeight(.thin)
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