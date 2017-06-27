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

class VirtualTouristMapViewController: UIViewController, ErrorFeedback {
    
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
    var photoService: PhotoService!
    var locationService: LocationFinderService!
    
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
        do {
            _ = Pin.init(location: location, context: objectContext)
            try self.objectContext.save()
            self.displayMapData()
        }
        catch {
            self.showErrorAlert(title: "Error Creating Pin", message:"Unable to Save" )
 
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
    
    // On selection - get pin model related to map annotation and start seguing
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        getPinForSelectedAnnotation{ (pin: Pin?) in
            guard let _ = pin else {
                // Rogue Pin! try and remove it from the map
                DispatchQueue.main.async {
                    if let annotation = view.annotation {
                        mapView.removeAnnotation(annotation)
                    }
                }
                return
            }

            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "PhotoCollectionViewController", sender: self)
            }
            
        }
    }
    
    // Helper
    
    func getPinForSelectedAnnotation(callback:@escaping (Pin?)->Void){
        
        self.objectContext.performAndWait {
            guard
                let pinId = (self.mapView.selectedAnnotations.first as? SimpleLocationAnnotation)?.entityId,
                let object = try? self.objectContext.existingObject(with: pinId),
                let pin = object as? Pin
                else {
                    callback(nil)
                    return
            }
            callback(pin)
        }
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
            
            guard let vc = segue.destination as? PhotoCollectionViewController else {
                print("Unrecognised vc in segue")
                return
            }
            
            // Setup presentation to be custom modal
            vc.transitioningDelegate = transitioningDelegate
            vc.modalPresentationStyle = .custom

            
            // Setup Detail View with location info 
            
            getPinForSelectedAnnotation(){ [weak vc] (pin:Pin?) in
                
                guard let pin = pin else {
                    return // we should have this covered in selection method
                }
                
                // 1) If location exists for pin, set next vc
                
                if let location = pin.locationInfo {
                    DispatchQueue.main.async {
                        vc?.setupDependencies(basedOn:location, from: self.objectContext, photoService:self.photoService)
                    }
                }
                
                // 2) if not async the data and update vc later 
                
                else {
                    DispatchQueue.main.async {
                        vc?.pendingPhotos = 10
                    }
                    
                    TouristLocation.create(basedOn: pin, locationService: self.locationService, context: self.objectContext).then { (location:TouristLocation) -> () in
                        
                        
                        DispatchQueue.main.async { () -> () in
                            vc?.setupDependencies(basedOn:location, from: self.objectContext, photoService: self.photoService)
                        }
                        
                        Photo.createBatch(basedOn: location, photoService: self.photoService, seed: 1, context: self.objectContext).always {
                            DispatchQueue.main.async {
                                vc?.pendingPhotos -= 1
                            }
                        }
                        // FIXME: What to do if photos fail?
                    }
                    .catch {_ in 
                        
                        // We Errored Creating location, dismiss Detail view
                        if let _ = vc {
                            print("Error Creating Location Entity")
                            self.navigationController?.popViewController(animated: true)
                            self.showErrorAlert(title: "Network Error", message:"Unable to request location info" )
                        }
                    }
                    
                    

                }
            }
            
        default:
            break
            
        }
        
        
    }
}
