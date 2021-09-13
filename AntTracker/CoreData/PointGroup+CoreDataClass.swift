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

    
    static func addUpdateGroup(group: PointGroup?,
                               moc: NSManagedObjectContext,
                               title: String,
                               info: String,
                               imageSymbol: String,
                               color: String,
                               showOnMap: Bool
                               ) {
        
        var groupForSave: PointGroup
        
        if group == nil {
            groupForSave = PointGroup(context: moc)
            groupForSave.id = UUID()
        } else {
            groupForSave = group!
        }
        
        groupForSave.dateOfLastChange = Date()
        groupForSave.title = title
        groupForSave.info = info
        groupForSave.imageSymbol = imageSymbol
        groupForSave.color = color
        groupForSave.showOnMap = showOnMap
        
        try? moc.save()
        
    }
    
    private func prepareForDelete(moc: NSManagedObjectContext) {
        
        if appVars.lastUsedPointGroup == self {
            appVars.lastUsedPointGroup = nil
        }
        
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

