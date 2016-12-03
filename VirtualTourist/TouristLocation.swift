//
//  TouristLocation+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 28/11/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//

import Foundation
import CoreData


public class TouristLocation: NSManagedObject {

    convenience init(name:String?, lat:Double, long:Double, context:NSManagedObjectContext){
        
        if let description = NSEntityDescription.entity(forEntityName: "TouristLocation", in: context) {
        
            self.init(entity: description, insertInto: context)
            self.name = name
            self.latitude = lat
            self.longitude = long
            
        }
        else {
            fatalError("Couldn't create Entity Description")
        }
    }
    
}
