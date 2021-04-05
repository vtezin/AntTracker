//
//  TrackInfo.swift
//  JustMap
//
//  Created by test on 05.04.2021.
//

import SwiftUI

struct TrackInfo: View {
    
    var geoTrack: GeoTrack
    
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
            
            if showFullInfo {
                
                VStack{
                    HStack {
                        Image(systemName: "timer")
                        Text(geoTrack.durationString)
                    }
                    HStack {
                        Image(systemName: "hare")
                        Text(" max \(geoTrack.maxSpeed.doubleKmH.string2s) km/h")
                    }
                    HStack {
                        Text("\(geoTrack.minAltitude)")
                        Image(systemName: "arrow.up.right")
                        Text("\(geoTrack.maxAltitude) m")
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
