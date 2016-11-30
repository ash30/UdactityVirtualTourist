//
//  MapViewDataSource.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 28/11/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//

import Foundation
import MapKit
import CoreData

// MARK: DATA SOURCE

protocol LocationCreator {
    
    var objectContext: NSManagedObjectContext! { get set }
    func createNew(_ location:CLLocation)
    
}

protocol MapViewDataSource: LocationCreator {
    
    var annotations: [MKAnnotation] { get }
    //var controller: MapViewController { get set }
        
}

