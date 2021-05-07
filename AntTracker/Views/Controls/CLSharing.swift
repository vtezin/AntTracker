//
//  CLSharing.swift
//  AntTracker
//
//  Created by test on 05.05.2021.
//

import SwiftUI
import CoreLocation

struct CLSharing: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var isNavigationBarHidden: Bool    
    @State var location: CLLocation
    
    var body: some View {
        
        
        Form{
            
            Section(header: Text("Coordinate format")) {
                
                ForEach(location.coordinateStrings, id: \.self) { coordinateString in
                    
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
        
        .onAppear {
            isNavigationBarHidden = false
        }
        .onDisappear{
            isNavigationBarHidden = true
        }
        
    }
    
}

//struct CLSharing_Previews: PreviewProvider {
//    static var previews: some View {
//        CLSharing()
//    }
//}
