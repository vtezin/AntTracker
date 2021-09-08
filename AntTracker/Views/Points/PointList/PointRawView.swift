//
//  PointRawView.swift
//  AntTracker
//
//  Created by test on 06.09.2021.
//

import SwiftUI

struct PointRawView: View {
    
    let point: Point
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            HStack{
                
                Image(systemName: point.wrappedImageSymbol)
                    .foregroundColor(.white)
                    .imageScale(.small)
                    .padding(10)
                    .background(Color.getColorFromName(colorName: point.wrappedColor))
                    .clipShape(Circle())
                
                VStack(alignment: .leading){
                    
                    Text(point.title)
                    
                    Text(point.dateAdded.dateString())
                        .modifier(SecondaryInfo())
                    
                }
                
                Spacer()
                
                if !point.wrappedInfo.isEmpty {
                    //HStack{
                        Text(point.wrappedInfo)
                            .modifier(SecondaryInfo())
                    //}
                }
                
            }
            
        }
    }
}

//struct PointRawView_Previews: PreviewProvider {
//    static var previews: some View {
//        PointRawView()
//    }
//}
