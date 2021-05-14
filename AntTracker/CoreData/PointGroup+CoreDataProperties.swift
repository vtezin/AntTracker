//
//  PointGroup+CoreDataProperties.swift
//  AntTracker
//
//  Created by test on 13.05.2021.
//
//

import Foundation
import CoreData


extension PointGroup {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PointGroup> {
        return NSFetchRequest<PointGroup>(entityName: "PointGroup")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var info: String?
    @NSManaged public var color: String?

}

extension PointGroup : Identifiable {

}
