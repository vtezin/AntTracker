//
//  CLSharing.swift
//  AntTracker
//
//  Created by test on 05.05.2021.
//

import SwiftUI
import CoreLocation

//FIXME: unused struct
struct CoordinatesSharing: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var coordinate: CLLocationCoordinate2D
    
    var body: some View {
                
        Form{
            
            Section(header: Text("Coordinate format")) {
                
                ForEach(coordinate.coordinateStrings, id: \.self) { coordinateString in
                    
                    Section {
                        
                        Button(action: {
                            
                            let av = UIActivityViewController(activityItems: [coordinateString], applicationActivities: nil)
                            UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
                            
                            //presentationMode.wrappedValue.dismiss()
                            
                        }) {
                            Text(coordinateString)
                                .padding()
                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        
        .navigationBarTitle("Share location", displayMode: .inline)
        
    }
    
}

//struct CLSharing_Previews: PreviewProvider {
//    static var previews: some View {
//        CoordinatesSharing()
//    }
//}
