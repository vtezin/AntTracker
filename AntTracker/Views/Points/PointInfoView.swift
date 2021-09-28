//
//  PointInfoView.swift
//  AntTracker
//
//  Created by test on 15.09.2021.
//

import SwiftUI
import MapKit

struct PointInfoView: View {
    
    let point: Point
    @EnvironmentObject var clManager: LocationManager
    @AppStorage("mainViewShowCurrentAlt") var mainViewShowCurrentAltitude: Bool = false
    
    var body: some View {
        
        VStack{
            
            if !point.wrappedInfo.isEmpty {
                Text(point.wrappedInfo).padding(3)
            }
            
            if !point.wrappedLocationString.isEmpty {
                Text(point.wrappedLocationString).padding(3)
                    .contextMenu {
                        Button {
                            let pasteBoard = UIPasteboard.general
                            pasteBoard.string = point.wrappedLocationString
                        } label: {
                            Label("Copy", systemImage: "arrow.right.doc.on.clipboard")
                        }
                    }
            }
            
            HStack{

                HStack{
                    Image(systemName: "location.fill")
                    Text(localeDistanceString(distanceMeters: clManager.location.distance(from: CLLocation(latitude: point.latitude, longitude: point.longitude))))
                }


                if mainViewShowCurrentAltitude {

                    Spacer()

                    //altitude

                    let altitudeDelta = point.wrappedAltitude - clManager.location.roundedAltitude

                    HStack{
                        Image(systemName: "arrow.up")
                        Text("\(point.wrappedAltitude) m")
                        if altitudeDelta != 0 {
                            Image(systemName: altitudeDelta > 0 ? "arrow.up.right" : "arrow.down.right")
                            Text("\(altitudeDelta) m")
                        }
                    }
                }

            }
            .font(.body)
            .padding(5)
            
        }
        .modifier(SecondaryInfo())
        
    }
}

//struct PointInfoView_Previews: PreviewProvider {
//    static var previews: some View {
//        PointInfoView()
//    }
//}
