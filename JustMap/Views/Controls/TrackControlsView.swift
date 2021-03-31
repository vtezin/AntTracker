//
//  TrackControlsView.swift
//  JustMap
//
//  Created by test on 11.03.2021.
//

import SwiftUI

struct TrackControlsView: View {
    
    @Environment(\.managedObjectContext) var moc
    @Binding var isNavigationBarHidden: Bool
    @ObservedObject var locationManager: LocationManager
    
    var body: some View {
                
            VStack {
                
                HStack {
                    
                    VStack{
                        
                        HStack {
                            
                            NavigationLink(destination: TrackListView(isNavigationBarHidden: $isNavigationBarHidden)) {
                                
                                Image(systemName: "folder")
                                    .font(Font.title.weight(.light))
                                
                            }
                            
                            Spacer()
                            
                            Text(locationManager.currentTrack.totalDistanceString(maxAccuracy: 10))
                                .font(.largeTitle)
                                .padding()
                            
                            Spacer()
                            
                            Image(systemName: locationManager.trackRecording ? "pause.circle" : "play.circle")
                                .font(Font.largeTitle.weight(.light))
                                //.imageScale(.large)
                                .onTapGesture() {
                                    locationManager.trackRecording.toggle()
                                }
                            
                        }
                        
                        HStack {
                            Image(systemName: "hare")
                            Text("\(locationManager.currentTrack.lastSpeed().doubleKmH().string2s()) (max \(locationManager.currentTrack.maxSpeed().doubleKmH().string2s()) ) km/h")
                            
                        }
                        .padding(.bottom)
                        
                    }
                    
                }
                
                if locationManager.currentTrack.points.count > 0 && !locationManager.trackRecording {
                    
                    HStack {
                        
                            
                        Image(systemName: "trash")
                            .font(Font.title.weight(.light))
                            .onTapGesture() {
                                locationManager.trackRecording = false
                                locationManager.currentTrack.reset()
                            }
                        
                        Spacer()
                        
                        Text("\(locationManager.currentTrack.points.count) points")
                            .font(.caption)
                        
                        if locationManager.currentTrack.trackCoreData == nil
                            || locationManager.currentTrack.points.count != locationManager.currentTrack.trackCoreData!.trackPointsArray.count {
                            
                            Spacer()
                            
                            Image(systemName: "square.and.arrow.down")
                                .font(Font.title.weight(.light))
                                .onTapGesture() {
                                    saveTrack()
                                }
                            
                        }
                        
                        
                    }
                    
                }
                
            }
        }
        
    func saveTrack() {
        
        locationManager.currentTrack.saveToDB(moc: moc)
        
    }
    
}

//struct TrackControlsView_Previews: PreviewProvider {
//    static var previews: some View {
//        TrackControlsView(recordingMode: .constant(.stop), track: .constant(Track()))
//    }
//}
