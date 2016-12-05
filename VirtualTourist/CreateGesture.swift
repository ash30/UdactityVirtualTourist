//
//  MapController.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 05/12/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//

import Foundation
import UIKit
import MapKit


// MARK: GESTURE TRAITS

protocol CreateGesture {
    func create(from handler:UIGestureRecognizer)
}

extension CreateGesture where Self: MapController {
    
    func create(from handler:UIGestureRecognizer){
        
        let pnt = mapView.convert(handler.location(in: mapView), toCoordinateFrom: mapView)
        let location = CLLocation.init(latitude: pnt.latitude, longitude: pnt.longitude)
        data?.createEntity(for: location)
        
    }
}
