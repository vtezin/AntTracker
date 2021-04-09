//
//  ColorSelectorView.swift
//  JustMap
//
//  Created by test on 05.04.2021.
//

import SwiftUI

struct ColorSelectorView: View {
    
    @Binding var selectedColor: Color
    var showPrimaryColor = false
    
    let colors = [
    Color.primary,
    Color.blue,
    Color.green,
    Color.red,
    Color.orange,
    Color.yellow,
    Color.purple]
    
    var body: some View {
        
        HStack(spacing: 10){
            
            ForEach(colors, id: \.self) { color in
                
                self.image(for: color)
                    .onTapGesture {
                        selectedColor = color
                }
                    .font(color == selectedColor ? .largeTitle : .title)
                
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
            return AnyView(Image(systemName: "circle.fill")
                .foregroundColor(color))
        default:
            return AnyView(Image(systemName: "circle")
                .foregroundColor(color))
        }
        
        
    }
}

struct ColorSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        ColorSelectorView(selectedColor: .constant(.blue))
    }
}
