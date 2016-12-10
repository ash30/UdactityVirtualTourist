//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 28/11/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//

import Foundation
import CoreData


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
    
    
}
