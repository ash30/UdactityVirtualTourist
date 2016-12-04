//
//  Pin+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 04/12/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//

import Foundation
import CoreData 

extension Pin {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin");
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var locationInfo: TouristLocation?

}
