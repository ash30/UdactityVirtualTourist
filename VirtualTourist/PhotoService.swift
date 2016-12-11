//
//  FlickrPhotoService.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 28/11/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//

import Foundation
import UIKit


/*

 The Photo Service returns a set of UIImages, randomised for a given location
 
 The provider has to return a fixed set of images based loc + page
 
 the provider cache's is where the prefetch happens
 
 It would be better if the photo service could take a callback which is called per photo
 provider returns list of photos promises!
 
 If I search the photos already, that should cache the images
 
 
*/


protocol PhotoService {
    
    // The service wil execute callback for each image
    func searchPhotos_byLocation(lat:Double, long:Double, seed: Int, callback: ((NamedImageData, Error?) -> Void)? )
    
}

protocol PhotoServicesEnabled {
    var photoServices: PhotoService { get set }
}


protocol PhotoServiceProvider: PhotoService {
    
    func searchPhotos_byLocation(lat:Double, long:Double, seed: Int) -> [Promise<NamedImageData>]

}


struct FlickrPhotoService {
    
    func searchPhotos_byLocation(lat:Double, long:Double, seed: Int) -> [Promise<NamedImageData>] {
        
        
        // BLAH BLAH
        let p = Promise<NamedImageData>()
        return [p]
        
    }
}

struct DefaultPhotoService: PhotoService{
    func searchPhotos_byLocation(lat:Double, long:Double, seed: Int, callback: ((NamedImageData, Error?) -> Void)? ) {
        
        if let callback = callback {
            
            let d: Data = UIImagePNGRepresentation(UIImage(named: "util-mark6")!)!
            
            
            callback(NamedImageData(data:d,name:"TEST"), nil)
            
        }
    }

}



