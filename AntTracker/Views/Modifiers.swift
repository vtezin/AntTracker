//
//  Modifiers.swift
//  JustMap
//
//  Created by test on 07.03.2021.
//

import SwiftUI

struct MapButton: ViewModifier {
    func body(content: Content) -> some View {
        
        ZStack {
            
            Image(systemName: "plus")
                
                .opacity(0.0)
            
            content

        }
        .imageScale(.small)
        .padding(15)
        .modifier(MapControlColors())
        //.font(.title)
        .font(Font.title.weight(.light))
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.systemBackground.opacity(0.8),
                        lineWidth: 1)
        )
        
    }
}

struct MapControl: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .modifier(MapControlColors())
    }
}

struct MapControlColors: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color(UIColor.systemBackground).opacity(0.5))
            .foregroundColor(.primary)
    }
}

