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
            
            .imageScale(.small)
            .font(Font.title.weight(.light))
            .padding(15)
            .modifier(MapControlColors())
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

struct ControlButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .imageScale(.small)
            .font(Font.title.weight(.light))
            .accentColor(.primary)
    }
}

struct SecondaryInfo: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.footnote)
            .foregroundColor(.secondary)
    }
}

struct MapControlColors: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color(UIColor.systemBackground).opacity(0.7))
            .accentColor(.primary)
    }
}

struct ClearButton: ViewModifier
{
    @Binding var text: String

    public func body(content: Content) -> some View
    {
        ZStack(alignment: .trailing)
        {
            content

            if !text.isEmpty
            {
                Button(action:
                {
                    self.text = ""
                })
                {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(UIColor.opaqueSeparator))
                }
                .padding(.trailing, 8)
            }
        }
    }
}

