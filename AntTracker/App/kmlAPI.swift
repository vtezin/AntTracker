//
//  kmlAPI.swift
//  AntTracker
//
//  Created by test on 06.07.2021.
//

import Foundation
import MapKit

enum kmlAPI {
    
    static func headerFile(title: String) -> String {
        
        let kmlText = """
        <?xml version=\"1.0\" encoding=\"UTF-8\"?>
        <kml xmlns=\"http://www.opengis.net/kml/2.2\">
        <Document>
        <name>\(title)</name>
        """
        
        return kmlText
        
    }
   
    static var footerFile: String {
        
        let kmlText = """
        </Document>
        </kml>
        """
        return kmlText
        
    }
    
    static func getCoordinateString(coordinate: CLLocationCoordinate2D, altitude: Double?) -> String {
        
        let latitudeString = String(coordinate.latitude)
        let longitudeString = String(coordinate.longitude)
        
        var altitudeString = ""
        if let altitude = altitude {
            altitudeString = String(altitude)
        }
            
        return "\(longitudeString),\(latitudeString),\(altitudeString) \n"
        
    }
    
    static func getPointTag(title: String, coordinate: CLLocationCoordinate2D, altitude: Double?) -> String {
        
        let coordinateString = getCoordinateString(coordinate: coordinate, altitude: altitude)
        
        let kmlText = """
        <Placemark>
        <name>\(title)</name>
        <Point>
        <tessellate>1</tessellate>
        <extrude>1</extrude>
        <coordinates>
        \(coordinateString)
        </coordinates>
        </Point>
        </Placemark>
        """
        
        return kmlText
        
    }
    
    static func shareTextAsKMLFile(text: String, filename: String) {

        // Convert the String into Data
        let textData = text.data(using: .utf8)

        // Write the text into a filepath and return the filepath in NSURL
        // Specify the file type you want the file be by changing the end of the filename (.txt, .json, .pdf...)
        let textURL = textData?.dataToFile(fileName: filename + ".kml")

        // Create the Array which includes the files you want to share
        var filesToShare = [Any]()

        // Add the path of the text file to the Array
        filesToShare.append(textURL!)

        // Make the activityViewContoller which shows the share-view

        // Show the share-view
        let av = UIActivityViewController(activityItems: filesToShare, applicationActivities: nil)
                UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
        
    }
    
    
}
