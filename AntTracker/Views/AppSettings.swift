//
//  AppSettings.swift
//  AntTracker
//
//  Created by test on 09.04.2021.
//

import SwiftUI

struct AppSettings: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var clManager: LocationManager
    
    @Binding var activePage: ContentView.pages
    
    @AppStorage("disableAutolockScreen") var disableAutolockScreen: Bool = false
    @AppStorage("currentTrackColor") var currentTrackColor: String = "orange"
    
    @AppStorage("mainViewShowCurrentAlt") var mainViewShowCurrentAltitude: Bool = false
    @AppStorage("mainViewShowCurrentSpeed") var mainViewShowCurrentSpeed: Bool = true
    
    @State var color: Color = .orange
    @State private var showColorSelector = false
    
    var body: some View {
        
        NavigationView{
            
            Form{
                
                Section(header: Text("Color of the current track")) {
                    ColorSelectorView(selectedColor: $color)
                }
                
                Section(header: Text("Display on the map")) {
                    Toggle(isOn: $mainViewShowCurrentSpeed.animation()) {
                        Text("Сurrent speed")
                    }
                    Toggle(isOn: $mainViewShowCurrentAltitude.animation()) {
                        Text("Сurrent altitude")
                    }
                    Text("(altitude according to GPS signal data)")
                        .modifier(SecondaryInfo())
                }
                
                Section {
                    Toggle(isOn: $disableAutolockScreen.animation()) {
                        Text("Disable auto-lock screen when app is active")
                    }
                    .onChange(of: disableAutolockScreen) { value in
                        UIApplication.shared.isIdleTimerDisabled = disableAutolockScreen
                    }
                }
                
            }
            
            .onAppear{
                color = Color.getColorFromName(colorName: currentTrackColor)
            }
            
            .onDisappear{
                currentTrackColor = color.description
            }
            
            .navigationBarTitle("Settings", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                withAnimation{activePage = .main}
            }) {HStack{
                Image(systemName: "chevron.backward")
                Text("Map")
            }
            },
            trailing: NavigationLink(destination:ThanksView()){Image(systemName: "hand.thumbsup")})
            
        }
            
        }

}

//struct AppSettings_Previews: PreviewProvider {
//    static var previews: some View {
//        AppSettings()
//    }
//}
