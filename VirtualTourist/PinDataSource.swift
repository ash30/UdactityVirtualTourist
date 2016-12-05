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

// MARK: PROTOCOLS

protocol PinDataSource: MapViewDataSource {
    
    var controller: NSFetchedResultsController<Pin> { get set }
    var objectContext: NSManagedObjectContext { get set }
    
}

extension PinDataSource {
    
    func totalAnnotations() -> Int {

        var i = 0
        
        objectContext.performAndWait {
            i = self.controller.fetchedObjects?.count ?? 0
        }
        
        return i
    }
    
    func getAnnotation(mapView:MKMapView, forIndex:Int) {
        
        objectContext.perform {
            
            if let locations = self.controller.fetchedObjects {
                
                let data = locations[forIndex]
                let annotation = SimpleLocationAnnotation.init(
                    latitude: data.latitude, longitude: data.longitude, entityId: data.objectID
                )
                
                DispatchQueue.main.async{
                    mapView.addAnnotation(annotation)
                }
            }
        }
    }
    
}


class PinMapDataSource: NSObject, PinDataSource, PinFactory, TouristLocationFactory, NSFetchedResultsControllerDelegate
 {
    
    // MARK: DEPS
    
    var controller: NSFetchedResultsController<Pin>
    var objectContext: NSManagedObjectContext
    
    weak var viewController: MapDataViewController?

    // MARK: INIT
    
    init(objectContext: NSManagedObjectContext, fetchResultController: NSFetchedResultsController<Pin>, viewController:MapDataViewController? ){
        
        // general property based init
       
        controller = fetchResultController
        self.objectContext = objectContext
        self.viewController = viewController
        
        super.init()
        
        // FIXME: What if fetch fails
        controller.delegate = self
        try? controller.performFetch()

    }
    
    convenience init( objectContext: NSManagedObjectContext){
        
        // setup data source based on object context
        
        let request: NSFetchRequest<Pin> = NSFetchRequest(entityName: Pin.entity().name!)
        request.fetchBatchSize = 10
        request.sortDescriptors = [NSSortDescriptor.init(key: "latitude", ascending: true)]
        
        let data = NSFetchedResultsController(fetchRequest: request, managedObjectContext: objectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        self.init(objectContext: objectContext, fetchResultController: data, viewController:nil)
        
    }
    
    // MARK: LOCATION CREATOR 
    
    func didFailCreation(_: Error) {
        fatalError()
    }
    
    // MARK: ??
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print ("Updated")
    }
    
    
    func didCreate(entity:NSManagedObjectID){
        objectContext.perform {
            if let pin = self.objectContext.object(with: entity) as? Pin {
                self.createTouristLocation(for:pin)
            }
            
        }
    }

    
}
