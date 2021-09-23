//
//  Modifiers.swift
//  JustMap
//
//  Created by test on 07.03.2021.
//

import SwiftUI

struct MapControlColors: ViewModifier {
    
    var disabled = false
    
    func body(content: Content) -> some View {
        content
            .background(Color(UIColor.systemBackground).opacity(disabled ? 0.3 : 0.7))
            .accentColor(disabled ? .secondary : .primary)
            //.foregroundColor(disabled ? .secondary : .primary)
    }
}

struct MapButton: ViewModifier {
    
    var disabled = false
    
    func body(content: Content) -> some View {
        
        content
            
            .imageScale(.small)
            .font(Font.title.weight(.light))
            .padding(15)
            .modifier(MapControlColors(disabled: disabled))
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(Color.systemBackground.opacity(disabled ? 0.4 : 0.8),
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
        
        //ZStack {
            content
                .imageScale(.small)
                .font(Font.title.weight(.light))
                .accentColor(.primary)
//            Image(systemName: "ant")
//                .imageScale(.small)
//                .font(Font.title.weight(.light))
//                .opacity(0)
//        }
        
    }
}

struct NavigationButton: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .imageScale(.large)
            .font(Font.title3.weight(.light))
    }
}

struct SecondaryInfo: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Font.footnote.weight(.light))
            .foregroundColor(.secondary)
    }
}

struct LightText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Font.subheadline.weight(.light))
    }
}

extension Text {
    func buttonText() -> some View {
        self.fontWeight(.light)
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.top, 1)
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

