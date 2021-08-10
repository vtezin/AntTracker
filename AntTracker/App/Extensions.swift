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
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: self)
        
    }
    
    /// Returns the amount of seconds from another date
     func seconds(from date: Date) -> Int {
         return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
     }
    
}

//extension for save and restore Date in AppStorage
extension Date: RawRepresentable {
    private static let formatter = ISO8601DateFormatter()
    
    public var rawValue: String {
        Date.formatter.string(from: self)
    }
    
    public init?(rawValue: String) {
        self = Date.formatter.date(from: rawValue) ?? Date()
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
    
    public static func getKmlColorByName(colorName: String) -> String {
        
        switch colorName {
        case "blue":
            return "64FF7800"
        case "green":
            return "5000BE14"
        case "red":
            return "501400FF"
        case "gray":
            return "50AAAAAA"
        case "orange":
            return "501478FF"
        case "yellow":
            return "5014F0FF"
        case "purple":
            return "50FF78F0"
        default:
            return "501478FF"
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

extension CLLocationCoordinate2D {
    
    var coordinateStrings: [String] {
        
        var stringsArray = [String]()
        
        stringsArray.append(latitudeDegrees + ", " + longitudeDegrees)
        stringsArray.append(latitudeDMS + ", " + longitudeDMS)
        stringsArray.append(String(format: "%.5f", latitude) + " "
                                + String(format: "%.5f", longitude))
        
        return stringsArray
    }
    
    var latitudeDMS: String {
        let (degrees, minutes, seconds) = latitude.dms
        return String(format: "%d°%d'%d\"%@", abs(degrees), minutes, seconds, degrees >= 0 ? "N" : "S")
    }
    var longitudeDMS: String {
        let (degrees, minutes, seconds) = longitude.dms
        return String(format: "%d°%d'%d\"%@", abs(degrees), minutes, seconds, degrees >= 0 ? "E" : "W")
    }
    
    var latitudeDegrees: String {
        return String(format: "%.5f", abs(latitude)) + "° " + (latitude >= 0 ? "N" : "S")
    }
    
    var longitudeDegrees: String {
        return String(format: "%.5f", abs(longitude)) + "° " + (longitude >= 0 ? "E" : "W")
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
        let valueForOutput = max(0, self.speedKmHRounded()) //speed is positive
        let speedInMSec = Measurement(value: valueForOutput, unit: UnitSpeed.metersPerSecond)
        formatter.unitStyle = MeasurementFormatter.UnitStyle.medium
        formatter.unitOptions = .naturalScale
        return formatter.string(from: speedInMSec)
        
    }
    
    func speedKmHRounded() -> Double {
        
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

func periodDescription(start startDate: Date?, end finishDate: Date?) -> String {
    
    if let startDate = startDate, let finishDate = finishDate {
        let dateInterval = DateInterval(start: startDate, end: finishDate)
        let formatter = DateIntervalFormatter()
        
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        return formatter.string(from: dateInterval)!
    } else {
        return ""
    }
    
}

//hiding keyboard
//https://www.hackingwithswift.com/quick-start/swiftui/how-to-dismiss-the-keyboard-for-a-textfield
#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif


//sharing files
//https://stackoverflow.com/questions/35851118/how-do-i-share-files-using-share-sheet-in-ios

extension Data {

    /// Data into file
    ///
    /// - Parameters:
    ///   - fileName: the Name of the file you want to write
    /// - Returns: Returns the URL where the new file is located in NSURL
    func dataToFile(fileName: String) -> NSURL? {

        // Make a constant from the data
        let data = self

        // Make the file path (with the filename) where the file will be loacated after it is created
        let filePath = getDocumentsDirectory().appendingPathComponent(fileName)

        do {
            // Write the file from data into the filepath (if there will be an error, the code jumps to the catch block below)
            try data.write(to: URL(fileURLWithPath: filePath))

            // Returns the URL where the new file is located in NSURL
            return NSURL(fileURLWithPath: filePath)

        } catch {
            // Prints the localized description of the error from the do block
            print("Error writing the file: \(error.localizedDescription)")
        }

        // Returns nil if there was an error in the do-catch -block
        return nil

    }

}

/// Get the current directory
///
/// - Returns: the Current directory in NSURL
func getDocumentsDirectory() -> NSString {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectory = paths[0]
    return documentsDirectory as NSString
}
