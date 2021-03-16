//
//  Modifiers.swift
//  JustMap
//
//  Created by test on 07.03.2021.
//

import SwiftUI

struct MapButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            //.padding()
            //.background(Color.primary.opacity(0.5))
            //.background(Color(UIColor.systemBackground).opacity(0.4))
            //.foregroundColor(.primary)
            .modifier(MapControl())
            .font(.title)
            .clipShape(Circle())
    }
}

struct MapControl: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(UIColor.systemBackground).opacity(0.5).clipShape(RoundedRectangle(cornerRadius: 20)))
            .foregroundColor(.primary)
    }
}
