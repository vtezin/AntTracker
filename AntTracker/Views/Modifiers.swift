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
            
            //for same sizes all buttons
            Image(systemName: "plus")
                .opacity(0.0)
            
            content

        }
        .imageScale(.small)
        .padding(15)
        .modifier(MapControlColors())
        .font(Font.title.weight(.light))
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.systemBackground.opacity(0.8),
                        lineWidth: 1)
        )
        
//        .overlay(
//            Circle()
//                .stroke(Color.gray,
//                        lineWidth: 1)
//        )
        
    }
}

struct MapControl: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .modifier(MapControlColors())
    }
}

struct TrackControlButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Font.largeTitle.weight(.light))
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
            //.foregroundColor(.primary)
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

