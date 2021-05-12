//
//  Colors.swift
//  AntTracker
//
//  Created by test on 11.05.2021.
//

import SwiftUI

struct Colors {
    
    static let colors = [
        Color.gray,
        Color.blue,
        Color.green,
        Color.red,
        Color.orange,
        Color.yellow,
        Color.purple]
    
    static func nextColor(fromColorWhithName: String?) -> Color {
        
        if let fromColorWhithName = fromColorWhithName {
            
            let fromColor = Color.getColorFromName(colorName: fromColorWhithName)
            
            let fromColorIndex = Colors.colors.firstIndex(of: fromColor) ?? 0
            
            if fromColorIndex == Colors.colors.count - 1 {
                return Colors.colors[0]
            } else {
                return Colors.colors[fromColorIndex + 1]
            }
            
        } else {
            return Colors.colors[0]
        }
        
    }
    
    
}
