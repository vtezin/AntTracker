//
//  ColorSelectorView.swift
//  JustMap
//
//  Created by test on 05.04.2021.
//

import SwiftUI

struct ColorSelectorView: View {
    
    @Binding var selectedColor: Color
    
    var imageForSelectedColor: String = "circle.fill"
    var imageForUnselectedColor: String = "circle"
    
    var showPrimaryColor = false
    
    var body: some View {
        
        HStack(){
            
            ForEach(Colors.colors, id: \.self) { color in
                
                image(for: color)
                    .onTapGesture {
                        selectedColor = color
                }
                    .font(.largeTitle)
                    .imageScale(color == selectedColor ? .large : .medium)
                
            }
            
        }
        .animation(.default)
        
    }
    
    func image(for color: Color) -> some View {
        
        switch color {
        
        case Color.primary:
            
            if showPrimaryColor {
                return AnyView(Image(systemName: "circle.lefthalf.fill")
                    .foregroundColor(color))
            } else {
                return AnyView(EmptyView())
            }
            
        case selectedColor:
            return AnyView(Image(systemName: imageForSelectedColor)
                .foregroundColor(color))
        default:
            return AnyView(Image(systemName: imageForUnselectedColor)
                .foregroundColor(color))
        }
        
        
    }
}

struct ColorSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        ColorSelectorView(selectedColor: .constant(.blue))
    }
}
