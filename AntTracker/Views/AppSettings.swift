//
//  AppSettings.swift
//  AntTracker
//
//  Created by test on 09.04.2021.
//

import SwiftUI

struct AppSettings: View {
    
    @AppStorage("disableAutolockScreenWhenTrackRecording") var disableAutolockScreenWhenTrackRecording: Bool = false
    @AppStorage("currentTrackColor") var currentTrackColor: String = "orange"
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var clManager: LocationManager
        
    @State var color: Color = .orange
    
    @Binding var activePage: ContentView.pages
    
    var body: some View {
        
        NavigationView{
            
            Form{
                
                Section(header: Text("Color of current track")) {
                    ColorSelectorView(selectedColor: $color)
                }
                
                Section {
                    Toggle(isOn: $disableAutolockScreenWhenTrackRecording.animation()) {
                        Text("Disable auto-lock screen when recording a track")
                    }
                }
                
            }
            
            .onAppear{
                color = Color.getColorFromName(colorName: currentTrackColor)
            }
            
            .onDisappear{
                currentTrackColor = color.description
                if disableAutolockScreenWhenTrackRecording {
                    UIApplication.shared.isIdleTimerDisabled = clManager.trackRecording
                }
            }
            
            .navigationBarTitle("Settings", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    activePage = .map
                }) {
                    HStack{
                        Image(systemName: "chevron.backward")
                        Text("Map")
                    }
                })
            
        }
            
            
        }

}

//struct AppSettings_Previews: PreviewProvider {
//    static var previews: some View {
//        AppSettings()
//    }
//}
