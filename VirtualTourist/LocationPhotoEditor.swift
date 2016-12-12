//
//  LocationPhotoEditor.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 11/12/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//

import Foundation
import CoreData

// Object for editing a locations assigned photos

protocol LocationPhotoEditor {
    var creator: EntityFactory { get }
    var objectContext: NSManagedObjectContext { get }
    
    func removePhoto(_ photo:Photo) throws
    func replacePhotos(for location:TouristLocation) -> Promise<Bool>
}

extension LocationPhotoEditor {
    
    func removePhoto(_ photo:Photo) throws {

        objectContext.delete(photo)
        do {
            try objectContext.save()
        }
    }
    
    func replacePhotos(for location:TouristLocation) -> Promise<Bool> {
        
        let result = Promise<Bool>()
        
        // 1) Mark the items for delete and save changes
        
        for p in (location.photos) ?? [] {
            objectContext.delete(p as! NSManagedObject)
        }
        do {
            try objectContext.save()
        }
        catch {
            
            // 2) If report any core data errors to caller

            result.reject(error: error)
            return result
            
        }
        
        // 3) all went well, now report Photo creation status

        creator.create(basedOn: location) { (p:Photo?, err:Error?) in
            
            guard err == nil else {
                result.reject(error: err!)
                return
            }
            result.resolve(value: true)
        }
        
        return result
    }

}