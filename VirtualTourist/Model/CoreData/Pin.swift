//
//  Pin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 02/12/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation


public class Pin: NSManagedObject {

    // Create a good initialiser 
    
    convenience init(lat:Double, long:Double, context:NSManagedObjectContext){
        
        if let description = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            
            self.init(entity: description, insertInto: context)
            self.latitude = lat
            self.longitude = long
            
        }
        else {
            fatalError("Couldn't create Entity Description")
        }
    }
    
    convenience init(location:CLLocation, context:NSManagedObjectContext) {
        
        let locationLat = location.coordinate.latitude
        let locationLong = location.coordinate.longitude
        self.init(lat:locationLat, long:locationLong, context:context )
        
    }
    

}

extension Pin {
    
    var locationFetchRequest: NSFetchRequest<TouristLocation> {
        
        let fetch: NSFetchRequest<TouristLocation> = TouristLocation.fetchRequest()
        fetch.fetchBatchSize = 1
        fetch.sortDescriptors = [NSSortDescriptor.init(key: nil, ascending: true)]
        
        fetch.predicate = NSPredicate(format: "%@ IN pins", argumentArray: [self])
        return fetch
    }
    
    
}
