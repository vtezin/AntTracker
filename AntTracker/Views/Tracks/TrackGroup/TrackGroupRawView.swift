//
//  TrackGroupRawView.swift
//  AntTracker
//
//  Created by test on 17.06.2021.
//

import SwiftUI

struct TrackGroupRawView: View {
    
    let trackGroup: TrackGroup?
    
    var body: some View {
        
        HStack{
            
            if trackGroup == nil {
                Text("< out of groups >")
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                
                ZStack {
                    Image(systemName: trackGroup!.wrappedImageSymbol)
                        .font(Font.title3.weight(.light))
                        .foregroundColor(.secondary)
                    Image(systemName: "bicycle")
                        .font(Font.title3.weight(.light))
                        .opacity(0)
                }
                Text(trackGroup!.wrappedTitle)
                Spacer()
                
            }
            
        }
        
    }
    
}

//struct TrackGroupRawView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackGroupRawView()
//    }
//}
