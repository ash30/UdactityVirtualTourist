//
//  SimpleLocation.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 01/12/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//

import Foundation
import MapKit
import CoreData

class SimpleLocationAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    let entityId: NSManagedObjectID
    
    init(latitude:Double, longitude:Double, entityId: NSManagedObjectID ){
        coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees.init(latitude), longitude: CLLocationDegrees.init(longitude)
        )
        self.entityId = entityId
    }    
}
