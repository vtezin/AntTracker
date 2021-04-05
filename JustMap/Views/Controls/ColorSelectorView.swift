//
//  ColorSelectorView.swift
//  JustMap
//
//  Created by test on 05.04.2021.
//

import SwiftUI

struct ColorSelectorView: View {
    @Binding var selectedColor: Color
    
    let colors = [
    Color.primary,
    Color.blue,
    Color.green,
    Color.red,
    Color.orange,
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
            return Image(systemName: "circle.lefthalf.fill")
                .foregroundColor(color)
        case selectedColor:
            return Image(systemName: "circle.fill")
                .foregroundColor(color)
        default:
            return Image(systemName: "circle")
                .foregroundColor(color)
        }
        
        
    }
}

struct ColorSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        ColorSelectorView(selectedColor: .constant(.blue))
    }
}
