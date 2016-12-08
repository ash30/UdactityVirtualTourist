//
//  PhotoCollectionViewController.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 03/12/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//

import Foundation
import UIKit
import CoreData


class PhotoCollectionViewController: UIViewController {
    
    // MARK: PROPERTIES
    
    @IBOutlet weak var LocationName: UILabel! {
        didSet{
            LocationName.font = UIFont(name: "HelveticaNeue-UltraLight", size: 40.0)
            LocationName.adjustsFontSizeToFitWidth = false
        }
    }
    @IBOutlet weak var PhotoCollection: UICollectionView!
    @IBOutlet var cellLayout: UICollectionViewFlowLayout!
  
    var touristLocationData: NSFetchedResultsController<TouristLocation>!
    var objectContext: NSManagedObjectContext!
    
}

// MARK: STORY BOARD INJECTION

extension PhotoCollectionViewController {
    
    func setupDependencies(basedOn:Pin, from objectContext:NSManagedObjectContext){
        
        self.objectContext = objectContext
        touristLocationData =  NSFetchedResultsController<TouristLocation>(
            fetchRequest: basedOn.locationFetchRequest, managedObjectContext:objectContext,
            sectionNameKeyPath: nil, cacheName: nil
        )
    }
}

// MARK: VC LIFE CYCLE

extension PhotoCollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLabelHeading()
        setCollectionView()
        touristLocationData.delegate = self
    }

    // MARK: SETUP HELPERS
    
    func setCollectionView(){
        PhotoCollection?.collectionViewLayout = cellLayout
        let containerWidth = view.frame.width
        let cellwidth = ((containerWidth/2) - 10)
        cellLayout.itemSize = CGSize.init(width: cellwidth, height: cellwidth)
    }
    
    func setLabelHeading(){
        objectContext.perform {
            guard
                let location = self.touristLocationData.fetchedObjects?.first,
                let name = location.name
            else {
                return
            }
            DispatchQueue.main.async {
                self.LocationName.text = name
            }
        }
    }
}

// MARK: DELEGATE

extension PhotoCollectionViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        setLabelHeading()
        touristLocationData.delegate = nil // no longer needed
    }
}

// MARK: COLLECTION VIEW


extension PhotoCollectionViewController: UICollectionViewDataSource {
    
    @objc func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return 10 - (touristLocationData.fetchedObjects?.first?.photos?.count ?? 0)
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "default", for: indexPath)
        
        // setup cell
        // blah
        
        return cell
    }
}


