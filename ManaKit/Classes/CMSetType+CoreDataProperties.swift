//
//  CMSetType+CoreDataProperties.swift
//  Pods
//
//  Created by Jovito Royeca on 15/04/2017.
//
//

import Foundation
import CoreData


extension CMSetType {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CMSetType> {
        return NSFetchRequest<CMSetType>(entityName: "CMSetType")
    }

    @NSManaged public var name: String?
    @NSManaged public var sets: NSSet?

}

// MARK: Generated accessors for sets
extension CMSetType {

    @objc(addSetsObject:)
    @NSManaged public func addToSets(_ value: CMSet)

    @objc(removeSetsObject:)
    @NSManaged public func removeFromSets(_ value: CMSet)

    @objc(addSets:)
    @NSManaged public func addToSets(_ values: NSSet)

    @objc(removeSets:)
    @NSManaged public func removeFromSets(_ values: NSSet)

}
