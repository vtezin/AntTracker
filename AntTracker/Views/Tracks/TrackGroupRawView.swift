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
            } else {
                Image(systemName: "folder")
                    .foregroundColor(.secondary)
                Text(trackGroup!.title)
            }
            
            Spacer()
            
        }
        
    }
}

//struct TrackGroupRawView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackGroupRawView()
//    }
//}