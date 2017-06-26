//
//  AppDelegate+Container.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 22/06/2017.
//  Copyright © 2017 AshArthur. All rights reserved.
//

import Foundation
import CoreData
import Swinject
import SwinjectStoryboard

extension AppDelegate {
    
    static let container:Container = {
        
        let container = Container()
        
        // MARK: CORE DATA
        
        container.register(NSPersistentContainer.self) { _ in
            
            let persistentData = NSPersistentContainer(name: "VirtualTourist")
            persistentData.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            persistentData.viewContext.mergePolicy = NSMergePolicy.rollback
            return persistentData
            
        }.inObjectScope(.container)
    
     
        // MARK: NETWORKING
        
        container.register(URLSession.self) { _ in
            let urlconfig = URLSessionConfiguration.default
            urlconfig.timeoutIntervalForRequest = 10
            urlconfig.timeoutIntervalForResource = 10
            return URLSession(configuration: urlconfig, delegate: nil, delegateQueue: nil)
            
        }.inObjectScope(.container)
        
        // VIEW CONTROLLERS 
        
        container.storyboardInitCompleted(VirtualTouristMapViewController.self){ r, vc in
            
            let persistentData = r.resolve(NSPersistentContainer.self)!
            let photoService = r.resolve(FlickrPhotoService.self)!
            vc.data = PinMapDataSource(objectContext: persistentData.viewContext)
            vc.objectContext = persistentData.viewContext
            vc.transitioningDelegate = r.resolve(MapViewTransitionDelegate.self)!
            vc.modalPresentationStyle = .custom

            vc.objectCreator = EntityFactory(
                context:  persistentData.viewContext,
                locationService: DefaultLocationFinder(), photoService: photoService )

        }
        
        // VIEW CONTROLLER TRANSITION DELEGATE
        container.register(MapViewTransitionDelegate.self){ r in
            return MapViewTransitionDelegate()
        }.inObjectScope(.container)
    
        
        // PHOTO SERVICE
        
        container.register(FlickrPhotoService.self){ r in
            
            let session = r.resolve(URLSession.self)!
            let networkController = HTTPClient(connection: session)
            return FlickrPhotoService(networkController: networkController)
        }
        
        return container
    }()
    
}
