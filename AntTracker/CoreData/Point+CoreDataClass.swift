//
//  Point+CoreDataClass.swift
//  AntTracker
//
//  Created by test on 13.05.2021.
//
//

import Foundation
import CoreData
import SwiftUI

@objc(Point)
public class Point: NSManagedObject {

    @discardableResult static func addUpdatePoint(point: Point?,
                               moc: NSManagedObjectContext,
                               title: String?,
                               info: String?,
                               locationString: String?,
                               color: String?,
                               imageSymbol: String?,
                               latitude: Double,
                               longitude: Double,
                               altitude: Double,
                               pointGroup: PointGroup?
    ) -> Point {
        
        var pointForSave: Point
        
        if point == nil {
            
            pointForSave = Point(context: moc)
            pointForSave.id = UUID()
            pointForSave.dateAdded = Date()
            pointForSave.latitude = latitude
            pointForSave.longitude = longitude
            pointForSave.altitude = altitude
            
        } else {
            pointForSave = point!
        }
        
        if let color = color {
            pointForSave.color = color
        } else {
            pointForSave.color = "orange"
        }
        
        if let imageSymbol = imageSymbol {
            pointForSave.imageSymbol = imageSymbol
        } else {
            pointForSave.imageSymbol = SFSymbolsAPI.pointDefaultImageSymbol
        }
        
        if let title = title {
            pointForSave.title = title
        } else {
            pointForSave.title = Date().dateString()
        }
        
        if let locationString = locationString {
            pointForSave.locationString = locationString
        }
        
        pointForSave.info = info
        
        pointForSave.pointGroup = pointGroup
        
        if let pointGroup = pointGroup {
            pointGroup.dateOfLastChange = Date()
        }
        
        try? moc.save()
        
        appVars.lastUsedPointGroup = pointGroup
        
        return pointForSave
        
    }
    
    static func deletePoint(point: Point, moc: NSManagedObjectContext) {
        
        moc.delete(point)
        try? moc.save()
        
    }
    
    func setLocationString(moc: NSManagedObjectContext,
                           locationString: String) {
        self.locationString = locationString
        try? moc.save()
    }
    
    static func textForKMLFile(title: String,
                                  coordinate: CLLocationCoordinate2D,
                                  altitude: Int) -> String {
        
        var kmlText = ""
        kmlText += kmlAPI.headerFile(title: title)
        kmlText += kmlAPI.getPointTag(title: title,
                                      coordinate: coordinate,
                                      altitude: Double(altitude))
        kmlText += kmlAPI.footerFile
        
        return kmlText
        
    }
    
    func textForKMLFile() -> String {
        
        return Point.textForKMLFile(title: wrappedTitle,
                              coordinate: coordinate,
                              altitude: wrappedAltitude)
        
    }
    
    func copyLocationToClipboard() {
        let pasteBoard = UIPasteboard.general
        pasteBoard.string = wrappedLocationString
    }
    
    func shareLocationString() {
        
        let sharedString = wrappedLocationString
        
        // Show the share-view
        let av = UIActivityViewController(activityItems: [sharedString], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
        
    }
    
    func shareCoordinatesString() {
        
        let sharedString = coordinate.coordinateStrings[2]
        
        // Show the share-view
        let av = UIActivityViewController(activityItems: [sharedString], applicationActivities: nil)
                UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
        
    }
    
    func shareAsKMLFile() {
        kmlAPI.shareTextAsKMLFile(
            text: textForKMLFile(),
                           filename: wrappedTitle)
    }
    
//    func getTextForKMLFile() -> String {
//        
//        var kmlText = "<?xml version=\"1.0\" encoding=\"UTF-8\"?> \n"
//        kmlText += "<kml xmlns=\"http://www.opengis.net/kml/2.2\"> \n"
//        kmlText += "<Document> \n"
//        kmlText += "<name>\(wrappedTitle)</name> \n"
//        kmlText += "<Placemark> \n"
//        kmlText += "<name>\(wrappedTitle)</name> \n"
//        kmlText += "<Point> \n"
//        kmlText += "<tessellate>1</tessellate> \n"
//        kmlText += "<coordinates> \n"
//        
//        let latitudeString = String(latitude)
//        let longitudeString = String(longitude)
//        
//        kmlText += "\(longitudeString),\(latitudeString) \n"
//        
//        kmlText += """
//        </coordinates>
//        </Point>
//        </Placemark>
//        </Document>
//        </kml>
//        """
//        
//        return kmlText
//        
//    }
    
}
