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
import CoreData

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
        data?.createEntity(for: location)
        
    }
}

// MARK: ????

class VirtualTouristMapViewController: UIViewController, CreateOnLongPress, MKMapViewDelegate {
    
    // MARK: PROPERTIES
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var longPessGesture: UILongPressGestureRecognizer! {
        didSet{
            longPessGesture.addTarget(self, action: #selector(self.longPresshandler))
        }
    }
    
    // MARK: DEPENDENCIES
    
    // FIXME
    var data: PinMapDataSource?
    var objectContext: NSManagedObjectContext!
    
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
        guard handler.state == .began else {
            return
        }
        createOnLongPress(handler)
        loadData()
    }
    
    // MARK: SEGUES
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //mapView.deselectAnnotation(mapView.selectedAnnotations.first!, animated: false)
        performSegue(withIdentifier: "PhotoCollectionViewController", sender: self)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let ident = segue.identifier else {
            return
        }
        
        
        switch ident {
        case "PhotoCollectionViewController":
            
            let vc = segue.destination as! PhotoCollectionViewController
            vc.setupDependencies(objectContext: objectContext)
            
            let pinId = (mapView.selectedAnnotations.first! as? SimpleLocationAnnotation)?.entityId
            
            if let pinId = pinId {
                objectContext.perform {
                    // FIXME OPTIONALS 
                    // ALSO DOESN'T WORK FOR NEWLY CREATED!! 
                    let pin = try? self.objectContext.existingObject(with: pinId)
                    try? vc.setCurrentTouristLocation(basedOn: pin as! Pin)
                }
            }
            mapView.deselectAnnotation(mapView.selectedAnnotations.first!, animated: false)


            
        default:
            break
            
        }
        
        
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
