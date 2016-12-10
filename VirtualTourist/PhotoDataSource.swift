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


protocol LivePhotoData: class, UICollectionViewDataSource {
    var delegate: NSFetchedResultsControllerDelegate? { get set }
}

// MARK: CONCRETE 

class VT_PhotoCollectionDataSource: NSObject, LivePhotoData {
    
    let controller: NSFetchedResultsController<Photo>
    let objectContext: NSManagedObjectContext

    init(controller: NSFetchedResultsController<Photo>, objectContext:NSManagedObjectContext){
        self.controller = controller
        self.objectContext = objectContext
        try? controller.performFetch() // FIXME: WHAT DO WE DO ABOUT ERRORS? 
        super.init()
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
    
    convenience init(location:TouristLocation, objectContext: NSManagedObjectContext){
        
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
        self.init(controller: controller, objectContext:objectContext)
    }
}

