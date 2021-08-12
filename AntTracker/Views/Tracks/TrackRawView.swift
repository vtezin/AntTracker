//
//  TrackRawView.swift
//  AntTracker
//
//  Created by test on 26.05.2021.
//

import SwiftUI

struct TrackRawView: View {
    
    let track: Track
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Text(track.title)
                .font(Font.subheadline.weight(.light))
            HStack{
                VStack(alignment: .leading){
                    Text(track.info)
                        .modifier(SecondaryInfo())
                }
                Spacer()
                VStack(alignment: .trailing){
                    Text(periodDescription(start: track.startDate, end: track.finishDate))
                    Text(localeDistanceString(distanceMeters: Double(track.totalDistance)))
                }
                .modifier(SecondaryInfo())
            }
            
        }
        
    }
}

//struct TrackRawView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackRawView()
//    }
//}
