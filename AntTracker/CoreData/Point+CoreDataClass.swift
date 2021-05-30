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
                               color: String?,
                               latitude: Double,
                               longitude: Double
    ) {
        
        var pointForSave: Point
        
        if point == nil {
            
            pointForSave = Point(context: moc)
            pointForSave.id = UUID()
            pointForSave.dateAdded = Date()
            pointForSave.latitude = latitude
            pointForSave.longitude = longitude
            
            print("\(latitude)  \(longitude)")
            
        } else {
            pointForSave = point!
        }
        
        if let color = color {
            pointForSave.color = color
        } else {
            pointForSave.color = "orange"
        }
        
        if let title = title {
            pointForSave.title = title
        } else {
            pointForSave.title = Date().dateString()
        }
        
        try? moc.save()
        
        
    }
    
}
