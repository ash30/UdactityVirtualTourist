//
//  TouristMapController.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 28/11/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation


// MARK: ?

protocol MapDataViewController: class {
    
    var mapView: MKMapView! { get set }
    var data: PinMapDataSource? { get set }
    
}

// MARK: ??

protocol CreateOnLongPress: MapDataViewController {
    func createOnLongPress( _ handler:UIGestureRecognizer)
}

extension CreateOnLongPress {
    
    func createOnLongPress( _ handler:UIGestureRecognizer){
        guard
            case handler.state = UIGestureRecognizerState.began
        else {
            return
        }
        
        let pnt = mapView.convert(handler.location(in: mapView), toCoordinateFrom: mapView)
        let location = CLLocation.init(latitude: pnt.latitude, longitude: pnt.longitude)
        data?.createPin(for: location)
        
    }
}

// MARK: ???

class VirtualTouristMapViewController: UIViewController, CreateOnLongPress {
    
    // MARK: PROPERTIES
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var longPessGesture: UILongPressGestureRecognizer! {
        didSet{
            longPessGesture.addTarget(self, action: #selector(self.longPresshandler))
        }
    }
    
    // MARK: DEPENDENCIES
    
    var data: PinMapDataSource?
    
    // MARK: LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup long press gesture
        mapView.addGestureRecognizer(longPessGesture)
        mapView.isUserInteractionEnabled = true
        
        // Load initial map view data
        loadData()
    }
    
    // MARK: TARGET ACTIONS
    
    @objc func longPresshandler(_ handler:UIGestureRecognizer){
        createOnLongPress(handler)
        loadData()
    }
    
    // MARK: HELPERS
    
    func loadData(){
        guard let data = data else {
            return
        }
        
        mapView.removeAnnotations(mapView.annotations)
        
        for i in 0 ..< (data.totalAnnotations() ) {
            data.getAnnotation(mapView: mapView, forIndex: i)
        }
    }
    
}
