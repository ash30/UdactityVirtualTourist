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


protocol MapDataViewController {
    var mapView: MKMapView! { get set }
    var data: MapViewDataSource? { get set }
}

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
        data?.createNew(location)
        
    }
}

protocol LoadMapViewData: MapDataViewController {
    func loadMapViewData()
}

extension LoadMapViewData {
    
    func loadData(){
        guard let data = data else {
            return
        }
        
        // refresh data in current map view
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(data.annotations)
    }
    
}

class VirtualTouristMapViewController: UIViewController, CreateOnLongPress, LoadMapViewData {
    
    // MARK: PROPERTIES
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var longPessGesture: UILongPressGestureRecognizer! {
        didSet{
            longPessGesture.addTarget(self, action: #selector(self.longPresshandler))
        }
    }
    
    // MARK: DEPENDENCIES
    
    var data: MapViewDataSource?
    
    // MARK: LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup long press gesture
        mapView.addGestureRecognizer(longPessGesture)
        mapView.isUserInteractionEnabled = true
        
        // Load Initial data
        loadData()
        
    }
    
    // MARK: TARGET ACTIONS
    
    @objc func longPresshandler(_ handler:UIGestureRecognizer){
        createOnLongPress(handler)
    }
    
    
}
