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
    var showStartFinishDates = true
    
    var body: some View {
        
        VStack {
            
            HStack{
                
                Text(geoTrack.totalDistanceString(maxAccuracy: 10))
                    .font(.title)
                
                Image(systemName: showFullInfo ? "chevron.up" : "chevron.down")
                    
                
            }
            .onTapGesture() {
                withAnimation{
                    showFullInfo.toggle()
                }
            }
            HStack {
                Text(geoTrack.durationString)
            }
            
            if showFullInfo {
                
                Divider()
                
                VStack{
                    
                    
                    HStack {
                        Image(systemName: "hare")
                        Text("max" + " \(geoTrack.maxSpeedPoint?.location.speed.localeSpeedString ?? "0")")
                    }
                    
                    
                    HStack {
                        Text("\(geoTrack.minAltitude)")
                        Image(systemName: "arrow.up.right")
                        Text("\(geoTrack.maxAltitude) " + "m")
                    }
 
                    if showStartFinishDates {
                        Divider()
                        VStack{
                            Text(geoTrack.startDate.dateString())
                            Text(geoTrack.finishDate.dateString())
                        }
                        .modifier(SecondaryInfo())
                    }
                    
                }
                
            }
            
        }
        .padding(5)
        
    }
}

//struct TrackInfo_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackInfo()
//    }
//}
