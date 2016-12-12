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
        
        // Helper func for creating new location
        // Create item with optionally provide name, report any error on save
        
        func onResult(name:String?){
            
            guard pin.locationInfo == nil else {
                return // Cannot edit existing? somebody called this twice...
            }
            
            self.context.perform {
                pin.locationInfo = TouristLocation(
                    name: name, lat: pin.latitude, long: pin.longitude,
                    context: self.context
                )
                do {
                    try self.context.save()
                    callback(pin.locationInfo,nil)
                }
                catch {
                    callback(nil,error)
                }
            }
        }
        
        // 1) Async Name for location and create location from result
        
        locationService.getNamefor(
            CLLocation(latitude: CLLocationDegrees.init(pin.latitude),
                       longitude: CLLocationDegrees.init(pin.longitude))
        )
        .then(
            onSuccess: { (name) -> Void in onResult(name:name)},
            onReject: { (err:Error) in
                
                // If the reason for failuer is no name found for place,
                // create a nameless place, otherwise error properlly 
                
                if err is LocationErrors {
                    switch err{
                    case LocationErrors.notFound:
                        onResult(name:nil)
                    default:
                        callback(nil,err)
                    }
                }
                else {
                    callback(nil,err)
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
    
    func create(basedOn location:TouristLocation, seed: Int,  callback:@escaping (Photo?,Error?) -> Void ) {
        
        // 1) Get async source of photo data
        
        photoService.searchPhotos_byLocation(
            lat: location.latitude, long: location.longitude, seed: seed
        ){ (image: NamedImageData?, err:Error?) -> Void in
            
            // 2) Check if network request was successful, report error to caller
            
            guard err == nil, let image = image else {
                callback(nil,err)
                return
            }
            
            // 3) Create Photo Entity and save, report any save errors
            
            self.context.perform {
                let p = Photo(
                    imageData: image.data, location: location, name: image.name, context: self.context
                )
                do {
                    try self.context.save()
                    callback(p,nil)
                }
                catch {
                    callback(nil,error)
                }
            }
        }
    
    }
    
    func prefetchPhotos(basedOn location:TouristLocation, seed: Int = 1) -> Promise<Bool> {
        
        // Makes a call to photo service so result is cached in URL cache for later creation
        
        let p = Promise<Bool>()
        
        photoService.searchPhotos_byLocation(
            lat: location.latitude, long: location.longitude, seed: seed)
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

