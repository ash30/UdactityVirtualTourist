//
//  SimpleLocation.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 01/12/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//

import Foundation
import MapKit

class SimpleLocationAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    
    init(latitude:Double, longitude:Double){
        coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees.init(latitude), longitude: CLLocationDegrees.init(longitude)
        )
    }    
}
