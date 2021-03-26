//
//  Extensions.swift
//  JustMap
//
//  Created by test on 25.03.2021.
//

import Foundation
import SwiftUI

extension Date {
    
    static var smallestDate: Date {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.date(from: "1800/01/01")!
        
    }
    
    func dateString() -> String {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
        
    }
    
}

extension Color {
    
    public static func getColorFromName(colorName: String) -> Color {
        
        switch colorName {
        case "blue":
            return Color.blue
        case "green":
            return Color.green
        case "red":
            return Color.red
        case "gray":
            return Color.gray
        case "orange":
            return Color.orange
        case "purple":
            return Color.purple
        default:
            return Color.primary
        }
        
    }
    
    static var systemBackground: Color {
        Color(UIColor.systemBackground)
    }
    
}
