//
//  Extensions.swift
//  JustMap
//
//  Created by test on 25.03.2021.
//

import Foundation
import SwiftUI
import CoreData
import MapKit

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
    
    func timeString() -> String {
        
        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .short
        formatter.dateFormat = "HH:mm"
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
        case "yellow":
            return Color.yellow
        case "purple":
            return Color.purple
        default:
            return Color.orange
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
    
    var coordinateDMS: String { latitudeDMS + " " + longitudeDMS }
    var coordinateDegrees: String {"\(coordinate.latitude) \(coordinate.longitude)"}
    
    var coordinateStrings: [String] {
        
        var stringsArray = [String]()
        
        stringsArray.append(latitudeDMS + ", " + longitudeDMS)
        stringsArray.append(String(format: "%.5f", coordinate.latitude) + " "
                                + String(format: "%.5f",coordinate.longitude))
        stringsArray.append(latitudeDegrees + ", " + longitudeDegrees)
        
        return stringsArray
    }
    
    var latitudeDMS: String {
        let (degrees, minutes, seconds) = coordinate.latitude.dms
        return String(format: "%d°%d'%d\"%@", abs(degrees), minutes, seconds, degrees >= 0 ? "N" : "S")
    }
    var longitudeDMS: String {
        let (degrees, minutes, seconds) = coordinate.longitude.dms
        return String(format: "%d°%d'%d\"%@", abs(degrees), minutes, seconds, degrees >= 0 ? "E" : "W")
    }
    
    var latitudeDegrees: String {
        return String(format: "%.5f", abs(coordinate.latitude)) + "° " + (coordinate.latitude >= 0 ? "N" : "S")
    }
    
    var longitudeDegrees: String {
        return String(format: "%.5f", abs(coordinate.longitude)) + "° " + (coordinate.longitude >= 0 ? "E" : "W")
    }
    
}

extension CLLocationSpeed {
    
    var localeSpeedString: String {
        
        let formatter = MeasurementFormatter()
        let valueForOutput = max(0, self.roundedForKmH()) //speed is positive
        let speedInMSec = Measurement(value: valueForOutput, unit: UnitSpeed.metersPerSecond)
        formatter.unitStyle = MeasurementFormatter.UnitStyle.medium
        formatter.unitOptions = .naturalScale
        return formatter.string(from: speedInMSec)
        
    }
    
    func roundedForKmH() -> Double {
        
        let speedKmH = self/1000 * 3600
    
        return speedKmH.rounded(toPlaces: 1) / 3600 * 1000
        
    }
    
}

extension Double {
    
    var string2s: String {
        return String(format: "%.2f", self)
    }
    
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
}

func localeDistanceString(distanceMeters: Double) -> String {
    
    if distanceMeters < 1 {
        return "0"
    } else {
        let formatter = MeasurementFormatter()
        let distanceInMeters = Measurement(value: Double(Int(distanceMeters)), unit: UnitLength.meters)
        formatter.unitStyle = MeasurementFormatter.UnitStyle.short
        formatter.unitOptions = .naturalScale
        
        return formatter.string(from: distanceInMeters)
    }
    
}

