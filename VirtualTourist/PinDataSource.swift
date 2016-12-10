//
//  MapViewDataSource.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 30/11/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class PinMapDataSource: NSObject, NSFetchedResultsControllerDelegate {
    
    // MARK: DEPS
    
    var controller: NSFetchedResultsController<Pin>
    var objectContext: NSManagedObjectContext
    
    // MARK: INIT
    
    init(objectContext: NSManagedObjectContext, fetchResultController: NSFetchedResultsController<Pin> ){
        
        controller = fetchResultController
        self.objectContext = objectContext
        super.init()
        
        controller.delegate = self
        try! controller.performFetch()
    }
    
    // MARK: FETCH CONTROLLER DELEGATE
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // For some reason, fetch results only refresh if we are a delegate?
    }
    
}

// MARK: ADDITIONAL INITS

extension PinMapDataSource {
    
    // setup data source based on object context
    
    convenience init( objectContext: NSManagedObjectContext){
        
        let request: NSFetchRequest<Pin> = NSFetchRequest(entityName: Pin.entity().name!)
        request.fetchBatchSize = 10
        request.sortDescriptors = [NSSortDescriptor.init(key: "latitude", ascending: true)]
        
        let data = NSFetchedResultsController(fetchRequest: request, managedObjectContext: objectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        self.init(objectContext: objectContext, fetchResultController: data)
        
    }
    
}

