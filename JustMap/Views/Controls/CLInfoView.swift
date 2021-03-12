//
//  CLInfoView.swift
//  JustMap
//
//  Created by test on 12.03.2021.
//

import SwiftUI
import CoreLocation

struct CLInfoView: View {
    
    @Binding var location: CLLocation
    
    var body: some View {
        
        HStack{
            
            VStack{
                
                Text("lt: \(location.coordinate.latitude)")
                Text("ln: \(location.coordinate.longitude)")
                Text("H. acc.: +/- \(location.horizontalAccuracy) m")
                
            }
            .padding()
            
            HStack{
                
                Text("alt: \(location.altitude)")
                Text("V. acc.: +/- \(location.verticalAccuracy) m")
                
            }
            .padding()
            
        }
        

        .font(.caption)
        
    }
}

//struct CLInfoView_Previews: PreviewProvider {
//    static var previews: some View {
//        CLInfoView()
//    }
//}
