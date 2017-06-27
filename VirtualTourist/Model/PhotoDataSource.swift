//
//  PhotoCollectionViewDataSource.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 05/12/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import PromiseKit


enum LivePhotoDataErrors: String, Error  {
    
    case noPhotosToReplace
    case networkError
    case coreDataError
    
}

protocol LivePhotoData: class, UICollectionViewDataSource {
    var delegate: NSFetchedResultsControllerDelegate? { get set }
    
    func replacePhotos() -> Promise<Bool>
    func removePhoto(index:IndexPath) -> Bool
}

// MARK: CONCRETE 

class VT_PhotoCollectionDataSource: NSObject {
    
    let controller: NSFetchedResultsController<Photo>
    let objectContext: NSManagedObjectContext
    let photoService: PhotoService
    var parentEntity: NSManagedObjectID?

    init(controller: NSFetchedResultsController<Photo>, objectContext:NSManagedObjectContext, photoService: PhotoService){
        self.controller = controller
        self.objectContext = objectContext
        self.photoService = photoService
        
        try? controller.performFetch() // FIXME: WHAT DO WE DO ABOUT ERRORS? 
        super.init()
    }
}

extension VT_PhotoCollectionDataSource: LivePhotoData, LocationPhotoEditor {
    
    func removePhoto(index:IndexPath) -> Bool {
        let photo = controller.object(at: index)
        
        do{
            try removePhoto(photo)
            return true
        }
        catch {
            return false
        }
    }
    
    func replacePhotos() -> Promise<Bool> {
        
        let result = Promise<Bool>.pending()

        // 1)  Make sure there are photos existing to replace
        var location: TouristLocation? = nil
        
        if let parent = parentEntity{
            location = objectContext.object(with: parent) as? TouristLocation
        }
        else{
            objectContext.performAndWait {
                location  = self.controller.fetchedObjects?.first?.location
            }
        }

        guard let loc = location else {
            result.reject(LivePhotoDataErrors.noPhotosToReplace)
            return result.promise
        }

        // 2) Next prefetch the replacement, no point replacing photos if the
        // network is down ...
        
        let newPhotoSeed = Int(arc4random_uniform(100))
        
        _ = self.replacePhotos(for: loc, newCollectionSeed: newPhotoSeed ).catch { _ in
            
            // FIXME: need to differentiate
            result.reject(LivePhotoDataErrors.coreDataError)
            //result.reject(LivePhotoDataErrors.networkError)

        }
        
        return result.promise
    }
    
}


// MARK: CollectionView interface

extension VT_PhotoCollectionDataSource: UICollectionViewDataSource {
    
    @objc func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return controller.fetchedObjects?.count ?? 0
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "photo", for: indexPath) as! CollectionViewPhotoCell

        
        objectContext.performAndWait {
            let photo = self.controller.object(at: indexPath)
            
            // display image 
            cell.image.image = UIImage(data: photo.image as Data)
        }
        return cell
        
        
    }
}
    
// MARK: Fetch Controller Delegate

extension VT_PhotoCollectionDataSource {

    var delegate: NSFetchedResultsControllerDelegate? {
        get {
            return controller.delegate
        }
        set(delegate) {
            controller.delegate = delegate
        }
    }
    
}

// MARK: INIT BASED ON LOCATION

extension VT_PhotoCollectionDataSource {
    
    convenience init(location:TouristLocation, objectContext: NSManagedObjectContext, photoService: PhotoService){
        
        let fetch: NSFetchRequest<Photo> = Photo.fetchRequest()
        fetch.fetchBatchSize = 10
        fetch.sortDescriptors = [NSSortDescriptor.init(key: "name", ascending: true)]
        
        // FIXME: WHY IS MANAGED OBJECT FAILABLE ?!?!
        let controller =  NSFetchedResultsController<Photo>(
            fetchRequest: fetch, managedObjectContext:objectContext,
            sectionNameKeyPath: nil, cacheName: nil
        )
        
        // ONLY SHOW PHOTOs FOR THIS LOCATION
        fetch.predicate = NSPredicate(format: "location == %@", argumentArray: [location])
        self.init(controller: controller, objectContext:objectContext, photoService: photoService)
        
        // Record Location for later
        parentEntity = location.objectID
        
    }
}


