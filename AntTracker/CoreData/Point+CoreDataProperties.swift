//
//  Point+CoreDataProperties.swift
//  AntTracker
//
//  Created by test on 13.05.2021.
//
//

import Foundation
import CoreData


extension Point {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Point> {
        return NSFetchRequest<Point>(entityName: "Point")
    }

    @NSManaged public var color: String?
    @NSManaged public var id: UUID
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var altitude: Double
    @NSManaged public var title: String?
    @NSManaged public var info: String?
    @NSManaged public var locationString: String?
    @NSManaged public var dateAdded: Date
    @NSManaged public var imageSymbol: String?
    @NSManaged public var pointGroup: PointGroup?
    
    public var wrappedImageSymbol: String {
        
        if let pointGroup = pointGroup {
            return pointGroup.wrappedImageSymbol
        }
        
        if let imageSymbol = imageSymbol {
            return imageSymbol
        } else {
            return SFSymbolsAPI.pointDefaultImageSymbol
        }
        
    }
    
    public var wrappedColor: String {
        
        if let pointGroup = pointGroup {
            return pointGroup.wrappedColor
        }
        
        if let color = color {
            return color
        } else {
            return globalParameters.defaultColor.description
        }
        
    }
    
    public var wrappedInfo: String {
        return info ?? ""
    }
    
    public var wrappedTitle: String {
        return title ?? ""
    }
    
    public var wrappedLocationString: String {
        return locationString ?? ""
    }
    
}

extension Point : Identifiable {

}
