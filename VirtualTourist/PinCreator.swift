//
//  MapViewDataSource_TouristLocationCreation.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 28/11/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CoreData

// MARK: PROTOCOLS

enum PinCreationMessages: String, RawRepresentableAsString{
    case created = "PinCreated"
    case failed = "PinCreationFailed"
}

protocol LocationFactory {
    
    var objectContext: NSManagedObjectContext { get set }
    func createEntity(for location:CLLocation)
    
    func didCreate(entity:NSManagedObjectID)
    func didFailCreation(_: Error)
}


protocol PinFactory: LocationFactory {
}

extension PinFactory {
    
    func createEntity(for location:CLLocation) {
        
        let locationLat = location.coordinate.latitude
        let locationLong = location.coordinate.longitude
        
        objectContext.performAndWait {
            let newEntity = Pin(lat: locationLat, long: locationLong, context: self.objectContext)
            do {
                try self.objectContext.save()
                self.didCreate(entity: newEntity.objectID)
            }
            catch {
                self.didFailCreation(error)
            }
        }
    }
    
}

// MARK: FULL CREATE

//protocol TouristLocationCreator: LocationCreator{
//    
//    var locationService: LocationService! { get set }
//    var photoService: FlickrService! { get set }
//    
//}
//
//extension TouristLocationCreator {
//    
//    func create(_ location:CLLocation, onError:@escaping (_ err:Error) -> Void ) {
//                
//        let locationName = locationService.getNamefor(location)
//        let locationLat = location.coordinate.latitude
//        let locationLong = location.coordinate.longitude
//        
//        // Attempt to make new TouristLocation
//        
//        
//        // FIXME !!
//        let t = TouristLocation(
//            name: nil, lat: locationLat, long: locationLong, context: self.objectContext!
//        )
//        
//        
//        locationName.then { (name:String) -> Promise<[UIImage]> in
//            
//            // Set locations name with decoded string
//            t.name = name
//            
//            return self.photoService.searchPhotos_byLocation(
//                lat: locationLat, long: locationLong
//            )
//            
//        }
//        .then(
//            onSuccess: { (images:[UIImage]) in
//                // cast images into photos and update t
//                
//                // and then save context so it flushes new object to parent
//                try? self.objectContext?.save()
//            },
//            
//            // If any of its fails:
//            onReject: { (err:Error) in
//                DispatchQueue.main.async{
//                    onError(err)
//                }
//                
//            }
//        )
//    }
//    
//}
