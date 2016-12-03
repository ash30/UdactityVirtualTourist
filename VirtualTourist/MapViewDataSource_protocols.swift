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

protocol MapViewDataSource {
    
    func totalAnnotations() -> Int
    func getAnnotation(mapView:MKMapView, forIndex:Int)
    
}

