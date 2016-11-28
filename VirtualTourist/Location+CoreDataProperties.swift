//
//  Location+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 28/11/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Pin");
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?
    @NSManaged public var photoExamples: NSOrderedSet?

}

// MARK: Generated accessors for photoExamples
extension Location {

    @objc(insertObject:inPhotoExamplesAtIndex:)
    @NSManaged public func insertIntoPhotoExamples(_ value: Photo, at idx: Int)

    @objc(removeObjectFromPhotoExamplesAtIndex:)
    @NSManaged public func removeFromPhotoExamples(at idx: Int)

    @objc(insertPhotoExamples:atIndexes:)
    @NSManaged public func insertIntoPhotoExamples(_ values: [Photo], at indexes: NSIndexSet)

    @objc(removePhotoExamplesAtIndexes:)
    @NSManaged public func removeFromPhotoExamples(at indexes: NSIndexSet)

    @objc(replaceObjectInPhotoExamplesAtIndex:withObject:)
    @NSManaged public func replacePhotoExamples(at idx: Int, with value: Photo)

    @objc(replacePhotoExamplesAtIndexes:withPhotoExamples:)
    @NSManaged public func replacePhotoExamples(at indexes: NSIndexSet, with values: [Photo])

    @objc(addPhotoExamplesObject:)
    @NSManaged public func addToPhotoExamples(_ value: Photo)

    @objc(removePhotoExamplesObject:)
    @NSManaged public func removeFromPhotoExamples(_ value: Photo)

    @objc(addPhotoExamples:)
    @NSManaged public func addToPhotoExamples(_ values: NSOrderedSet)

    @objc(removePhotoExamples:)
    @NSManaged public func removeFromPhotoExamples(_ values: NSOrderedSet)

}
