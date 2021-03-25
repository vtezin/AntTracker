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
        .font(.title)
        .clipShape(Circle())
        
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

