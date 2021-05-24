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
                Text(geoTrack.durationString)
                    .modifier(SecondaryInfo())
                Spacer()
                Image(systemName: showFullInfo ? "chevron.up" : "chevron.down")
                
            }
            
            .onTapGesture() {
                withAnimation{
                    showFullInfo.toggle()
                }
            }
            
            if showFullInfo {
                
                HStack{
                    
                    VStack {
                        HStack{
                            Image(systemName: "hare")
                            if !showingSavedTrack {
                                Text(clManager.location.speed.localeSpeedString)
                            }
                        }
                        Divider()
                        Text("max" + " \(geoTrack.maxSpeedPoint?.location.speed.localeSpeedString ?? "0")")
                            .modifier(SecondaryInfo())
                    }
                    
                    Spacer()
                    
                    VStack {
                        HStack{
                            Image(systemName: "arrow.up")
                            if !showingSavedTrack {
                                Text(String(format: "%.0f", clManager.location.altitude) + " " + "m")
                            }
                        }
                        Divider()
                        HStack{
                        Text("\(geoTrack.minAltitude)")
                        Image(systemName: "arrow.up.right")
                            Text("\(geoTrack.maxAltitude)")
                            Text("(\(geoTrack.maxAltitude - geoTrack.minAltitude)) " + "m")
                        }
                            .modifier(SecondaryInfo())
                    }
                    
                    
                    
                }
                .padding(.top)
                
                if showingSavedTrack {
                    Divider()
                    VStack{
                        Text(geoTrack.startDate.dateString())
                        Text(geoTrack.finishDate.dateString())
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
