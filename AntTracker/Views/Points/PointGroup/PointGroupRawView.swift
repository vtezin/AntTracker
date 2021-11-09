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
            
            if group == nil {
                Text("< out of groups >")
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                
                HStack{
                    group!.imageView
                    VStack(){
                        
                        Text(group!.wrappedTitle)
                        
                        if !group!.wrappedInfo.isEmpty {
                            HStack{
                                Text(group!.wrappedInfo)
                                    .modifier(SecondaryInfo())
                            }
                        }
                        
                    }
                    
                    if !group!.showOnMap {
                        Image(systemName: "eye.slash")
                            .foregroundColor(.secondary)
                            .imageScale(.small)
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
