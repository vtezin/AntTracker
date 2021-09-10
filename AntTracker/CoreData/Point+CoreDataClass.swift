//
//  Point+CoreDataClass.swift
//  AntTracker
//
//  Created by test on 13.05.2021.
//
//

import Foundation
import CoreData

@objc(Point)
public class Point: NSManagedObject {

    static func addUpdatePoint(point: Point?,
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
    ) {
        
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
        
        try? moc.save()
        
        
    }
    
    func getTextForKMLFile() -> String {
        
        var kmlText = "<?xml version=\"1.0\" encoding=\"UTF-8\"?> \n"
        kmlText += "<kml xmlns=\"http://www.opengis.net/kml/2.2\"> \n"
        kmlText += "<Document> \n"
        kmlText += "<name>\(wrappedTitle)</name> \n"
        kmlText += "<Placemark> \n"
        kmlText += "<name>\(wrappedTitle)</name> \n"
        kmlText += "<Point> \n"
        kmlText += "<tessellate>1</tessellate> \n"
        kmlText += "<coordinates> \n"
        
        let latitudeString = String(latitude)
        let longitudeString = String(longitude)
        
        kmlText += "\(longitudeString),\(latitudeString) \n"
        
        kmlText += """
        </coordinates>
        </Point>
        </Placemark>
        </Document>
        </kml>
        """
        
        return kmlText
        
    }
    
}
