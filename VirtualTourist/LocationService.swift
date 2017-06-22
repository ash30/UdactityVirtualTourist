//
//  LocationService.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 28/11/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//

import Foundation
import CoreLocation
import PromiseKit

enum LocationErrors: Error{
    case notFound
}

protocol LocationFinderService {
    
    var geoEncoder: CLGeocoder { get set }
    func getNamefor(_ location:CLLocation) -> Promise<String>
    
}

extension LocationFinderService {
    
    func getNamefor(_ location:CLLocation) -> Promise<String> {
        
        let p = Promise<String>.pending()
        
        geoEncoder.reverseGeocodeLocation(location){ (place: [CLPlacemark]?, error: Error?) -> Void in
            
            guard error == nil else {
                p.reject(error!)
                return 
            }
            
            guard let placeName = place?.first?.locality else {
                p.reject(LocationErrors.notFound)
                return
            }
            p.fulfill(placeName)
        }
        return p.promise
    }
    
}

protocol LocationServiceEnabled {
    var locationServices: LocationFinderService { get set }
}


class DefaultLocationFinder: LocationFinderService {

    var geoEncoder: CLGeocoder = CLGeocoder()

}


