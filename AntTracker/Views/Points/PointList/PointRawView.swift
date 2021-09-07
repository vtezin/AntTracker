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
                
                Text(point.title)
                    .font(Font.subheadline.weight(.light))
            }
            
            Text(point.dateAdded.dateString())
                        .modifier(SecondaryInfo())
            
        }
    }
}

//struct PointRawView_Previews: PreviewProvider {
//    static var previews: some View {
//        PointRawView()
//    }
//}
