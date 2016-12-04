//
//  PhotoCollectionViewController.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 03/12/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol TouristLocationView {
    
    var objectContext: NSManagedObjectContext! { get set }
    var touristLocationData: NSFetchedResultsController<TouristLocation>! { get }
    func setCurrentTouristLocation(basedOn entity:Pin) throws
    
}

extension TouristLocationView {

    func setCurrentTouristLocation(basedOn entity:Pin) throws  {
        if let cacheName = touristLocationData?.cacheName {
            NSFetchedResultsController<TouristLocation>.deleteCache(withName: cacheName)
        }
        touristLocationData?.fetchRequest.predicate = NSPredicate(format: "%@ IN pins", argumentArray: [entity])
        try touristLocationData?.performFetch()
    }
    
}

class PhotoCollectionViewController: UIViewController, TouristLocationView {
    
    // MARK: PROPERTIES
    
    @IBOutlet weak var LocationName: UILabel!
    @IBOutlet weak var PhotoCollection: UICollectionView!
    var touristLocationData: NSFetchedResultsController<TouristLocation>!
    var objectContext: NSManagedObjectContext!
    
    // MARK: LIFE CYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setViewState()
    }
    
    // MARK: HELPERS
    
    func setViewState(){
        objectContext.perform {
            if let currentTouristLocation = self.touristLocationData.fetchedObjects?.first {
                
                let name = currentTouristLocation.name
                
                DispatchQueue.main.async {
                    self.LocationName.text = name ?? ""
                }
            }
        }
    }

}

extension PhotoCollectionViewController {
    
    func setupDependencies(objectContext:NSManagedObjectContext){
        
        self.objectContext = objectContext
        
        let fetch: NSFetchRequest<TouristLocation> = TouristLocation.fetchRequest()
        fetch.fetchBatchSize = 1
        fetch.sortDescriptors = [NSSortDescriptor.init(key: "latitude", ascending: true)]
        
        touristLocationData =  NSFetchedResultsController<TouristLocation>(fetchRequest: fetch, managedObjectContext:objectContext, sectionNameKeyPath: nil, cacheName: nil)
    }
}
