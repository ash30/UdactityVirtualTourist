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

struct DefaultPhotoService: PhotoService{
    func searchPhotos_byLocation(lat:Double, long:Double, seed: Int, callback: ((NamedImageData?, Error?) -> Void)? ) {
        
        if let callback = callback {
            
            let d: Data = UIImagePNGRepresentation(UIImage(named: "util-mark6")!)!
            
            
            callback(NamedImageData(data:d,name:"TEST"), nil)
            
        }
    }

}

struct FlickrPhotoService: PhotoService {
    
    let serviceProvider: FlickrPhotoProvider
    
    func searchPhotos_byLocation(lat:Double, long:Double, seed: Int, callback: ((NamedImageData?, Error?) -> Void)? ) {
        
        // 1) Get a list of photo references
        
        let photos = serviceProvider.searchPhotos_byLocation(lat: lat, long: long, seed: 1)
        
        photos.then(
            onSuccess: { (refs:[FlickrPhotoReference]) in
            
                guard let callback = callback else {
                    return // nothing to report
                }
                
                // 2) Download the photo based on ref data
                
                for r in refs[0...9] {
                    
                    self.serviceProvider.getPhoto(r).then(
                        
                        // 3) Report back result
                        
                        onSuccess: { (d:Data) in
                            let image = NamedImageData(data:d,name:r.title)
                            callback(image,nil)
                        },
                        onReject: { (err:Error) in
                            callback(nil,err)
                        }
                    )
                }
            },
            onReject: { (err:Error) in
            
                // notify that initial call failed
                
                if let callback = callback {
                    callback(nil,err)
                }
                
            }
        )
    }
}

// MARK: Convienence Init

extension FlickrPhotoService {
    
    init (networkController:NetworkController) {
        
        let provider = FlickrPhotoProvider(resourceServerDetails: FlickServiceConfig(), network: networkController)
        self.init(serviceProvider: provider)
        
    }
    
}







