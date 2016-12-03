//
//  Pin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 02/12/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//

import Foundation
import CoreData


public class Pin: NSManagedObject {

    // Create a good initialiser 
    
    convenience init(lat:Double, long:Double, context:NSManagedObjectContext){
        
        if let description = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            
            self.init(entity: description, insertInto: context)
            self.latitude = lat
            self.longitude = long
            
        }
        else {
            fatalError("Couldn't create Entity Description")
        }
    }
    
}

