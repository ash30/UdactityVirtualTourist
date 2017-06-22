//
//  FlickrPhotoService.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 28/11/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//

import Foundation
import UIKit


protocol PhotoService {
    
    // The service wil execute callback for each image
    func searchPhotos_byLocation(lat:Double, long:Double, seed: Int, callback: ((NamedImageData?, Error?) -> Void)? )
    
}

// MARK: FLICKR

struct FlickrPhotoService: PhotoService {
    
    let serviceProvider: FlickrPhotoProvider
    
    func searchPhotos_byLocation(lat:Double, long:Double, seed: Int, callback: ((NamedImageData?, Error?) -> Void)? ) {
        
        // 1) Get a list of photo references
        
        let photos = serviceProvider.searchPhotos_byLocation(lat: lat, long: long, seed: seed)
        
        guard let callback = callback else {
            return // nothing to report
        }
        
        _ = photos.then { (refs:[FlickrPhotoReference]) -> () in
            
            for r in refs[0..<min(10,refs.count)] {
                self.serviceProvider.getPhoto(r)
                .then{ (d:Data) -> () in
                    let image = NamedImageData(data:d,name:r.title)
                    callback(image,nil)
                }
                .catch { (err:Error) in
                    callback(nil,err)
                }
            }
        }
        .catch {
            (err:Error) in
            // notify that initial call failed
            callback(nil,err)

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

struct DefaultPhotoService: PhotoService{
    func searchPhotos_byLocation(lat:Double, long:Double, seed: Int, callback: ((NamedImageData?, Error?) -> Void)? ) {
        
        if let callback = callback {
            
            let d: Data = UIImagePNGRepresentation(UIImage(named: "util-mark6")!)!
            
            
            callback(NamedImageData(data:d,name:"TEST"), nil)
            
        }
    }
    
}







