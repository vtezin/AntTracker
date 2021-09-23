//
//  PointRawView.swift
//  AntTracker
//
//  Created by test on 06.09.2021.
//

import SwiftUI

struct PointRawView: View {
    
    let point: Point
    let showPointImage: Bool
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            HStack{
                
                if showPointImage {
                    point.imageView
                }
                
                VStack(alignment: .leading){
                    
                    Text(point.wrappedTitle)
                        .modifier(LightText())
                    
                    Text(point.dateAdded.dateString())
                        .modifier(SecondaryInfo())
                    
                }
                
                Spacer()
                
//                if !point.wrappedLocationString.isEmpty {
                        Text(point.wrappedLocationString)
                            .modifier(SecondaryInfo())
//                }
                
            }
            
        }
    }
}

//struct PointRawView_Previews: PreviewProvider {
//    static var previews: some View {
//        PointRawView()
//    }
//}
