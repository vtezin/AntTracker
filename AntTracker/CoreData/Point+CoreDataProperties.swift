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

    @NSManaged public var color: String
    @NSManaged public var id: UUID
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var altitude: Double
    @NSManaged public var title: String
    @NSManaged public var dateAdded: Date
    @NSManaged public var imageSymbol: String?
    
    public var wrappedImageSymbol: String {
        
        if let imageSymbol = imageSymbol {
            return imageSymbol
        } else {
            return SFSymbolsAPI.pointDefaultImageSymbol
        }
        
    }
    
    
}

extension Point : Identifiable {

}
