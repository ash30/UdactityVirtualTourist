//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 10/12/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//

import Foundation
import CoreData 

extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var name: String?
    @NSManaged public var image: NSData
    @NSManaged public var location: TouristLocation?

}
