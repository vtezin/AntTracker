//
//  PointGroupRawView.swift
//  AntTracker
//
//  Created by test on 06.09.2021.
//

import SwiftUI

struct PointGroupRawView: View {
    
    let group: PointGroup?
    
    var body: some View {
        
        HStack{
            
            if group == nil {
                Text("< out of groups >")
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                
                HStack{
                    
                    ZStack {
                        Image(systemName: group!.wrappedImageSymbol)
                            .foregroundColor(.white)
                            .imageScale(.medium)
                            .padding(10)
                            .background(Color.getColorFromName(colorName: group!.wrappedColor))
                            .clipShape(Circle())
                        Image(systemName: "bicycle")
                            .font(Font.title3.weight(.light))
                            .opacity(0)
                    }
                    
                    Image(systemName: group!.showOnMap ? "eye" : "eye.slash")
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading){
                        
                        Text(group!.title)
                        
                        if !group!.wrappedInfo.isEmpty {
                            HStack{
                                Text(group!.wrappedInfo)
                                    .modifier(SecondaryInfo())
                            }
                        }
                        
                    }
                    
                    Spacer()
                    
                    Text("\(group!.pointsArray.count)")
                        .modifier(SecondaryInfo())
                    
                }
                
            }
            
        }
        
    }
    
}

//struct PointGroupRawView_Previews: PreviewProvider {
//    static var previews: some View {
//        PointGroupRawView()
//    }
//}
