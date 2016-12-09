//
//  EntityCreator.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 05/12/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CoreData

class EntityFactory: PinFactory, TouristLocationFactory, PhotoFactory {

    internal var context: NSManagedObjectContext
    internal var locationService: LocationFinderService
    internal var photoService: PhotoService
    
    init (context: NSManagedObjectContext, locationService:LocationFinderService, photoService: PhotoService) {
        self.context = context
        self.locationService = locationService
        self.photoService = photoService
    }
}

protocol EntityCreator {
    var objectCreator : EntityFactory { get set }
}


// MARK: PIN FACTORY

protocol PinFactory{
    var context: NSManagedObjectContext { get }
}

extension PinFactory {
    
    func create(basedOn location:CLLocation, callback:@escaping (Pin?,Error?) -> Void) {
        
        let locationLat = location.coordinate.latitude
        let locationLong = location.coordinate.longitude
        
        context.performAndWait {
            let newEntity = Pin(lat: locationLat, long: locationLong, context: self.context)
            do {
                try self.context.save()
                callback(newEntity,nil)
            }
            catch{
                callback(nil,error)
            }
        }
    }
}

// MARK: TOURIST LOCATION

protocol TouristLocationFactory {
    var context: NSManagedObjectContext { get }
    var locationService: LocationFinderService { get set }
}

extension TouristLocationFactory {
    
    func create(basedOn pin:Pin, callback:@escaping (TouristLocation?,Error?) -> Void) {
        
        locationService.getNamefor(
            CLLocation(latitude: CLLocationDegrees.init(pin.latitude),
                       longitude: CLLocationDegrees.init(pin.longitude))
            )
            .then(onSuccess: { (name) -> Void in
                
                self.context.perform {
                    pin.locationInfo = TouristLocation(
                        name: name, lat: pin.latitude, long: pin.longitude,
                        context: self.context
                    )
                    callback(pin.locationInfo,nil)
                }
                
                },
                  onReject: { (err) in
                    
                    self.context.perform {
                        pin.locationInfo = TouristLocation(
                            name: nil, lat: pin.latitude, long: pin.longitude,
                            context: self.context
                        )
                        callback(pin.locationInfo,nil)
                        
                    }
                }
        )
    }
}

// MARK: PHOTO FACTORY

protocol PhotoFactory {
    var context: NSManagedObjectContext { get }
    var photoService: PhotoService { get set }
}

extension PhotoFactory {
    
    func create(basedOn location:TouristLocation, callback:@escaping (Photo?,Error?) -> Void) {
        
        photoService.searchPhotos_byLocation(
            lat: location.latitude, long: location.longitude, seed: 1
        ){ (image: UIImage, err:Error?) -> Void in
            
            guard err == nil else {
                callback(nil,err)
                return
            }
            
            self.context.perform {
                let p = Photo(context: self.context)
                callback(p,nil)
            }
        }
    
    }
    
}

