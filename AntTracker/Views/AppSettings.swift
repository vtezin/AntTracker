//
//  AppSettings.swift
//  AntTracker
//
//  Created by test on 09.04.2021.
//

import SwiftUI

struct AppSettings: View {
    
    @Binding var activePage: ContentView.pages
    
    @AppStorage("disableAutolockScreen") var disableAutolockScreen: Bool = false
    @AppStorage("currentTrackColor") var currentTrackColor: String = "orange"
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var clManager: LocationManager
        
    @State var color: Color = .orange
    @State private var showColorSelector = false
    
    var body: some View {
        
        NavigationView{
            
            Form{
                
                Section(header: Text("Color of current track")) {
                    ColorSelectorView(selectedColor: $color, showSelectorOnRequestor: $showColorSelector)
                }
                
                Section {
                    Toggle(isOn: $disableAutolockScreen.animation()) {
                        Text("Disable auto-lock screen")
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
            .navigationBarItems(
                leading: Button(action: {
                    withAnimation{
                        activePage = .main
                    }
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
