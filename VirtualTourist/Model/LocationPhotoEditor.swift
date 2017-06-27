//
//  LocationPhotoEditor.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 11/12/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//

import Foundation
import CoreData
import PromiseKit

// Object for editing a locations assigned photos

protocol LocationPhotoEditor {
    var photoService: PhotoService { get }
    var objectContext: NSManagedObjectContext { get }
    
    func removePhoto(_ photo:Photo) throws
    func replacePhotos(for location:TouristLocation, newCollectionSeed:Int) -> Promise<Bool>

}

extension LocationPhotoEditor {
    
    func removePhoto(_ photo:Photo) throws {

        objectContext.delete(photo)
        do {
            try objectContext.save()
        }
    }
    
    func replacePhotos(for location:TouristLocation, newCollectionSeed:Int) -> Promise<Bool> {
        
        let result = Promise<Bool>.pending()
        
        // 1) Mark the items for delete and save changes
        
        for p in (location.photos) ?? [] {
            objectContext.delete(p as! NSManagedObject)
        }
        do {
            try objectContext.save()
        }
        catch {
            
            // 2) If report any core data errors to caller
            print(error)
            result.reject(error)
            return result.promise
            
        }
        
        // 3) all went well, now report Photo creation status
        Photo.createBatch(basedOn: location, photoService: photoService, seed: newCollectionSeed, context: objectContext) .then { _ -> () in
            do {
                try self.objectContext.save()
                result.fulfill(true)
            }
            catch {
                result.reject(error)
            }
        }
        .catch { (err:Error) in
            // FIXME: Should probably rollback context at this point?
            result.reject(err)
        }
        return result.promise
    }

}
