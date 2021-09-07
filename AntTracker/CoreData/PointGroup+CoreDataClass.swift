//
//  PointGroup+CoreDataClass.swift
//  AntTracker
//
//  Created by test on 13.05.2021.
//
//

import Foundation
import CoreData

@objc(PointGroup)
public class PointGroup: NSManagedObject {

    func prepareForDelete(moc: NSManagedObjectContext) {
        
        for point in pointsArray {
            point.pointGroup = nil
        }
        try? moc.save()
        
    }
    
    static func deleteGroup(group: PointGroup, moc: NSManagedObjectContext) {
        
        group.prepareForDelete(moc: moc)
        moc.delete(group)
        try? moc.save()
        
    }
    
}

