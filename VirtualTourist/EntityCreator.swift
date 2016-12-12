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
    
    func create(basedOn location:CLLocation, callback:@escaping (Pin?,Error?) -> Void) {
        // call default implementation
        (self as PinFactory).create(basedOn: location, callback: callback)
        
        // additionally, start prefetching photos
        photoService.searchPhotos_byLocation(lat: location.coordinate.latitude, long: location.coordinate.longitude, seed: 1, callback: nil)
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
                
                guard pin.locationInfo == nil else {
                    return // Cannot edit existing / somebody called this twice...
                }
                
                self.context.perform {
                    pin.locationInfo = TouristLocation(
                        name: name, lat: pin.latitude, long: pin.longitude,
                        context: self.context
                    )
                    callback(pin.locationInfo,nil)
                }
                
                },
                  onReject: { (err) in
                    
                    guard pin.locationInfo == nil else {
                        return
                    }
                    
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
    
    func create(basedOn location:TouristLocation, callback:@escaping (Photo?,Error?) -> Void ) {
        
        photoService.searchPhotos_byLocation(
            lat: location.latitude, long: location.longitude, seed: 1
        ){ (image: NamedImageData?, err:Error?) -> Void in
            
            guard err == nil, let image = image else {
                callback(nil,err)
                return
            }
            
            self.context.perform {
                let p = Photo(
                    imageData: image.data, location: location, name: image.name, context: self.context
                )
                callback(p,nil)
            }
        }
    
    }
    
    func prefetchPhotos(basedOn location:TouristLocation) -> Promise<Bool> {
        
        let p = Promise<Bool>()
        
        photoService.searchPhotos_byLocation(
            lat: location.latitude, long: location.longitude, seed: 1)
        { (image: NamedImageData?, err:Error?) -> Void in

            // Inform the client of prefetching success
            
            guard err == nil, let image = image else{
                p.reject(error: err!)
                return
            }
            p.resolve(value: true )
        }
        return p
    }
    
    
}

