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

protocol PinCreator {
    
    var objectContext: NSManagedObjectContext? { get set }
    func createPin(for location:CLLocation)
    func didFailCreation(_: Error)
    
}

extension PinCreator {
    
    func createPin(for location:CLLocation) {
        
        guard let context = objectContext else {
            return
        }
        
        let locationLat = location.coordinate.latitude
        let locationLong = location.coordinate.longitude
        
        context.perform {
            Pin(lat: locationLat, long: locationLong, context: context)
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
