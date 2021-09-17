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

                    group!.imageView
                    
                    if !group!.showOnMap {
                        Image(systemName: "eye.slash")
                            .foregroundColor(.secondary)
                    }
                    
                    
                    VStack(alignment: .leading){
                        
                        Text(group!.title)
                        
                        if !group!.wrappedInfo.isEmpty {
                            HStack{
                                Text(group!.wrappedInfo)
                                    .modifier(SecondaryInfo())
                            }
                        }
                        
                    }
                    
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
