//
//  Point+CoreDataProperties.swift
//  AntTracker
//
//  Created by test on 13.05.2021.
//
//

import Foundation
import CoreData
import MapKit
import SwiftUI

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
            return AppConstants.defaultColor.description
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
    
    public var wrappedAltitude: Int {
        return Int(altitude)
    }
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude,
                                      longitude: longitude)
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

extension Point : Identifiable {

}
