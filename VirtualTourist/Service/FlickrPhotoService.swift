//
//  FlickrPhotoService.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 28/11/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//

import Foundation
import UIKit
import PromiseKit


protocol PhotoService {
    
    // The service wil execute callback for each image
    func searchPhotos_byLocation(lat:Double, long:Double, seed: Int) -> Promise<[Promise<NamedImageData>]>
    
}

// MARK: FLICKR

struct FlickrPhotoService: PhotoService {
    
    let serviceProvider: FlickrPhotoProvider
    
    func searchPhotos_byLocation(lat:Double, long:Double, seed: Int) -> Promise<[Promise<NamedImageData>]> {
        
        let photos = serviceProvider.searchPhotos_byLocation(lat: lat, long: long, seed: seed)
        
        return photos.then { (refs:[FlickrPhotoReference]) -> ([Promise<NamedImageData>]) in
            
            (refs[0..<min(10,refs.count)]).map{ (r:FlickrPhotoReference) -> Promise<NamedImageData> in
                self.serviceProvider.getPhoto(r).then{ NamedImageData(data:$0,name:r.title)}
            }
        }
    }
    
}


extension FlickrPhotoService {
    
    // MARK: Convienence Init
    
    init (networkController:NetworkController) {
        
        let provider = FlickrPhotoProvider(resourceServerDetails: FlickServiceConfig(), network: networkController)
        self.init(serviceProvider: provider)
        
    }
    
}

// MARK: Debug Service

//struct DefaultPhotoService: PhotoService{
//    func searchPhotos_byLocation(lat:Double, long:Double, seed: Int, callback: ((NamedImageData?, Error?) -> Void)? ) {
//        
//        if let callback = callback {
//            
//            let d: Data = UIImagePNGRepresentation(UIImage(named: "util-mark6")!)!
//            
//            
//            callback(NamedImageData(data:d,name:"TEST"), nil)
//            
//        }
//    }
//    
//}







