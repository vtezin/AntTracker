//
//  PointGroup+CoreDataProperties.swift
//  AntTracker
//
//  Created by test on 13.05.2021.
//
//

import Foundation
import CoreData
import SwiftUI

extension PointGroup {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PointGroup> {
        return NSFetchRequest<PointGroup>(entityName: "PointGroup")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String
    @NSManaged public var info: String?
    @NSManaged public var color: String?
    @NSManaged public var showOnMap: Bool
    @NSManaged public var imageSymbol: String?
    @NSManaged public var dateOfLastChange: Date
    @NSManaged public var point: NSSet?
    
    public var pointsArray: [Point] {
        let set = point as? Set<Point> ?? []
        return set.sorted {
            $0.dateAdded < $1.dateAdded
        }
    }
    
    public var wrappedImageSymbol: String {
        
        if let imageSymbol = imageSymbol {
            return imageSymbol
        } else {
            return SFSymbolsAPI.pointDefaultImageSymbol
        }
        
    }
    
    public var wrappedColor: String {
        
        if let color = color {
            return color
        } else {
            return AppConstants.defaultColor.description
        }
        
    }
    
    public var wrappedInfo: String {
        return info ?? ""
    }
    
    public var imageView: some View {
        
        ZStack{
            
            Image(systemName: wrappedImageSymbol)
                .foregroundColor(.white)
                .imageScale(.medium)
            
            Image(systemName: "bicycle")
                .imageScale(.medium)
                .opacity(0)
        }
        .padding(7)
        .background(Color.getColorFromName(colorName: wrappedColor))
        .clipShape(Circle())
        
    }
    
}

extension PointGroup : Identifiable {

}
