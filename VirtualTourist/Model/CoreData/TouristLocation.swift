//
//  TouristLocation+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 28/11/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//

import Foundation
import CoreData
import PromiseKit
import CoreLocation


public class TouristLocation: NSManagedObject {

    convenience init(name:String?, lat:Double, long:Double, context:NSManagedObjectContext){
        
        if let description = NSEntityDescription.entity(forEntityName: "TouristLocation", in: context) {
        
            self.init(entity: description, insertInto: context)
            self.name = name
            self.latitude = lat
            self.longitude = long
            
        }
        else {
            fatalError("Couldn't create Entity Description")
        }
    }
    
    class func create(basedOn pin:Pin, locationService: LocationFinderService, context:NSManagedObjectContext) -> Promise<TouristLocation>{
        
        // 1) Async Name for location and create location from result
        
        let locationName = locationService.getNamefor(
            CLLocation(latitude: CLLocationDegrees.init(pin.latitude),
                       longitude: CLLocationDegrees.init(pin.longitude))
            )
        return locationName.then { (name) -> (TouristLocation) in
            TouristLocation(
                name: name, lat: pin.latitude, long: pin.longitude,
                context: context
            )
        }
    }
    
}

extension TouristLocation {
    
    var photoFetchRequest: NSFetchRequest<Photo> {
        
        let fetch: NSFetchRequest<Photo> = Photo.fetchRequest()
        fetch.fetchBatchSize = 10
        fetch.sortDescriptors = [NSSortDescriptor.init(key: nil, ascending: true)]
        
        fetch.predicate = NSPredicate(format: "location == %@", argumentArray: [self])
        return fetch
    }
    
    
}
