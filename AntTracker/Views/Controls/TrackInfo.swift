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
                Image(systemName: "timer")
                Text(geoTrack.durationString)
            }
            
            if showFullInfo {
                
                Divider()
                
                VStack{
                    
                    HStack {
                        Image(systemName: "hare")
                        Text("max" + " \(geoTrack.maxSpeedPoint?.location.speed.doubleKmH.string2s ?? "0") " + "km/h")
                    }
                    
                    
                    HStack {
                        Text("\(geoTrack.minAltitude)")
                        Image(systemName: "arrow.up.right")
                        Text("\(geoTrack.maxAltitude) " + "m")
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
