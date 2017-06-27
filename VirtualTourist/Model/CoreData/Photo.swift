//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 28/11/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//

import Foundation
import CoreData
import PromiseKit

public class Photo: NSManagedObject {

    convenience init(imageData: Data, location:TouristLocation, name:String?, context:NSManagedObjectContext ) {
        
        if let description = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            
            self.init(entity: description, insertInto: context)
            image = imageData as NSData
            self.name = name
            self.location = location
        }
        else {
            fatalError("Couldn't create Entity Description")
        }
    }
    
 
    class func createBatch(basedOn location:TouristLocation, photoService: PhotoService, seed: Int, context:NSManagedObjectContext) -> Promise<[Promise<Photo>]>{
        
        return photoService.searchPhotos_byLocation(lat:location.latitude, long:location.longitude, seed: seed).then { (response:[Promise<NamedImageData>]) -> [Promise<Photo>] in
            
            response.map{ (image: Promise<NamedImageData>) -> Promise<Photo> in
                image.then { (data:NamedImageData) -> Photo in
                    Photo(
                        imageData: data.data, location: location, name: data.name, context:context
                    )
                }
            }
        }
    }
    
}
