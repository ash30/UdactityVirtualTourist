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

extension PinMapDataSource: MapViewDataSource {
    
    func totalAnnotations() -> Int {
        
        var i = 0
        
        objectContext.performAndWait {
            i = self.controller.fetchedObjects?.count ?? 0
        }
        
        return i
    }
    
    func getAnnotation(mapView:MKMapView, forIndex:Int) {
        
        objectContext.perform {
            
            if let locations = self.controller.fetchedObjects {
                
                let data = locations[forIndex]
                let annotation = SimpleLocationAnnotation.init(
                    latitude: data.latitude, longitude: data.longitude, entityId: data.objectID
                )
                
                DispatchQueue.main.async{
                    mapView.addAnnotation(annotation)
                }
            }
        }
    }
    
}
