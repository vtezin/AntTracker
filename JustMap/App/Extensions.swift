//
//  Extensions.swift
//  JustMap
//
//  Created by test on 25.03.2021.
//

import Foundation
import SwiftUI
import CoreData

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

extension BinaryFloatingPoint {
    var dms: (degrees: Int, minutes: Int, seconds: Int) {
        var seconds = Int(self * 3600)
        let degrees = seconds / 3600
        seconds = abs(seconds % 3600)
        return (degrees, seconds / 60, seconds % 60)
    }
}

extension CLLocation {
    var dms: String { latitude + " " + longitude }
    var latitude: String {
        let (degrees, minutes, seconds) = coordinate.latitude.dms
        return String(format: "%d°%d'%d\"%@", abs(degrees), minutes, seconds, degrees >= 0 ? "N" : "S")
    }
    var longitude: String {
        let (degrees, minutes, seconds) = coordinate.longitude.dms
        return String(format: "%d°%d'%d\"%@", abs(degrees), minutes, seconds, degrees >= 0 ? "E" : "W")
    }
}

extension CLLocationSpeed {
    
    var doubleKmH: Double {
        return self/1000 * 60 * 60
    }
    
}

extension Double {
    
    var string2s: String {
        return String(format: "%.2f", self)
    }
    
}

extension CLLocation {
    
    var speedKmH: String {
        
        if speed <= 0 {
            return "0"
        }
        
        let doubleSpeed = Double(speed)
        //convert to km/h
        let doubleSpeedKmH = doubleSpeed/1000 * 60 * 60
        return String(format: "%.1f", doubleSpeedKmH)
        
    }
    
}
