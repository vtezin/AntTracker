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
            .padding()
            .background(Color.primary.opacity(0.5))
            .foregroundColor(.orange)
            //.font(.)
            .clipShape(Circle())
    }
}
