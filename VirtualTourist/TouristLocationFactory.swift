//
//  TouristLocationFactory.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 03/12/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData


protocol TouristLocationFactory  {
    
    var objectContext: NSManagedObjectContext { get set }
    func didFailCreation(_: Error)
    
}

extension TouristLocationFactory {
    
    func createTouristLocation(for pin:Pin){
        
        //DispatchQueue.global(qos: .userInitiated).async {
            
        // Do some work and then contruct tourist location
        let name = "TEST"
            
        self.objectContext.perform {
            pin.locationInfo = TouristLocation(
                name: name, lat: pin.latitude, long: pin.longitude,
                context: self.objectContext
            )
        }
    }

}
