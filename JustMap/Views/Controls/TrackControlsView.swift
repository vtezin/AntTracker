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
    
    @State private var showFullInfo = false
    
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
                            
                            HStack{
                                
                                Text(locationManager.currentTrack.totalDistanceString(maxAccuracy: 10))
                                    .font(.largeTitle)
                                    .padding()
                                
                                Image(systemName: showFullInfo ? "chevron.up" : "chevron.down")
                                    .onTapGesture() {
                                        withAnimation{
                                            showFullInfo.toggle()
                                        }
                                    }
                                
                            }
                            
                            
                            Spacer()
                            
                            Image(systemName: locationManager.trackRecording ? "pause.circle" : "play.circle")
                                .font(Font.largeTitle.weight(.light))
                                .onTapGesture() {
                                    withAnimation{
                                    locationManager.trackRecording.toggle()
                                    }
                                }
                            
                        }
                        .onTapGesture() {
                            withAnimation{
                                showFullInfo.toggle()
                            }
                        }
                        
                        if showFullInfo {
                            
                            VStack{
                                HStack {
                                    Image(systemName: "timer")
                                    Text(locationManager.currentTrack.durationString)
                                }
                                HStack {
                                    Image(systemName: "hare")
                                    Text(" max \(locationManager.currentTrack.maxSpeed.doubleKmH.string2s) km/h")
                                }
                                HStack {
                                    Text("\(locationManager.currentTrack.minAltitude)")
                                    Image(systemName: "arrow.up.right")
                                    Text("\(locationManager.currentTrack.maxAltitude) m")
                                }
                            }
                            
                        }
                        
                        
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
