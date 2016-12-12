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
import CoreData


// MARK: IMPLEMENTATION

class VirtualTouristMapViewController: UIViewController {
    
    // MARK: PROPERTIES
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var longPessGesture: UILongPressGestureRecognizer! {
        didSet{
            longPessGesture.addTarget(self, action: #selector(self.longPresshandler))
        }
    }
    
    // MARK: DEPENDENCIES
    
    var data: PinMapDataSource?
    var objectContext: NSManagedObjectContext!
    var objectCreator: EntityFactory!
    
    // MARK: LIFECYCLE
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup long press gesture
        mapView.addGestureRecognizer(longPessGesture)
        mapView.isUserInteractionEnabled = true
        
        // Load initial map view data
        displayMapData()
    }
    
    // MARK: TARGET ACTIONS
    
    @objc func longPresshandler(_ handler:UIGestureRecognizer){
        guard handler.state == .began else {
            return
        }
        let pnt = mapView.convert(handler.location(in: mapView), toCoordinateFrom: mapView)
        let location = CLLocation.init(latitude: pnt.latitude, longitude: pnt.longitude)
        
        objectCreator.create(basedOn: location){ (pin:Pin?, err:Error?) in
            
            guard let pin = pin, err == nil else {
                return // FIXME: How to handle Error?
            }
            
            DispatchQueue.main.async {
                // Display New Data
                self.displayMapData()
            }
            
        }
        
    }
    
    // MARK: HELPERS
    
    func displayMapData(){
        
        guard let data = data else {
            return
        }
        
        mapView.removeAnnotations(mapView.annotations)
        
        for i in 0 ..< (data.totalAnnotations() ) {
            data.getAnnotation(mapView: mapView, forIndex: i)
        }
    }
    
}

// MARK: MAP DELEGATE

extension VirtualTouristMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        performSegue(withIdentifier: "PhotoCollectionViewController", sender: self)
        
    }
    
}

// MARK: SEGUES

extension VirtualTouristMapViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let ident = segue.identifier else {
            return
        }
        
        defer {
            mapView.deselectAnnotation(mapView.selectedAnnotations.first!, animated: false)
        }
        
        
        switch ident {
        case "PhotoCollectionViewController":
            
            let vc = segue.destination as! PhotoCollectionViewController
            
            let pinId = (mapView.selectedAnnotations.first! as? SimpleLocationAnnotation)?.entityId
            if let pinId = pinId {
                objectContext.perform { [weak vc] in
                    
                    guard
                        let object = try? self.objectContext.existingObject(with: pinId),
                        let pin = object as? Pin,
                        let vc = vc
                    else {
                        return
                        // Really we should message vc to say NO DATA PAL!
                    }
                    
                    if let location = pin.locationInfo {
                        DispatchQueue.main.async {
                            vc.setupDependencies(basedOn:location, from: self.objectContext, creator:self.objectCreator)
                        }
                    }
                        
                    else { // defer setup until we have full location info
                        self.objectCreator.create(basedOn: pin){ (l:TouristLocation?, err:Error?) in
                            guard err == nil, let l=l else {
                                return // WHAT DO WE DO IF THIS ERRORED???
                            }
                            self.objectCreator.create(basedOn: l, seed: 1) { (p:Photo?, err:Error?) in
                                
                                print(l,p)
                                // DO SOMETHING ABOUT ERROR
                                
                            }
                            
                            
                            DispatchQueue.main.async {
                                vc.setupDependencies(basedOn:l, from: self.objectContext, creator:self.objectCreator)
                            }
                            
                        }
                    }
                    
                }
            }
            
            
            
        default:
            break
            
        }
        
        
    }
}
