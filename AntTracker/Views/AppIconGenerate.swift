//
//  AppIconGenerate.swift
//  AntTracker
//
//  Created by test on 05.04.2021.
//

import SwiftUI

struct AppIconGenerate: View {
    var body: some View {
        
        ZStack{
            
            LinearGradient(gradient: Gradient(colors: [.gray, .black]), startPoint: .top, endPoint: .bottom)
            
            VStack{
                Spacer()
                Spacer()
                Image(systemName: "ant")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .imageScale(.large)
                    .frame(width: 512, height: 512, alignment: .bottom)
                Spacer()

            }
            
            
        }
        

    }
}

struct AppIconGenerate_Previews: PreviewProvider {
    static var previews: some View {
        AppIconGenerate()
    }
}
