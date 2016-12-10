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
    @IBOutlet weak var PhotoCollection: UICollectionView! {
        didSet{
            PhotoCollection.dataSource = self
        }
    }
    @IBOutlet var cellLayout: UICollectionViewFlowLayout!
    var photos: LivePhotoData?
    
}

// MARK: STORY BOARD INJECTION

extension PhotoCollectionViewController {
    
    func setupDependencies(basedOn location:TouristLocation, from objectContext:NSManagedObjectContext){
        
        photos = VT_PhotoCollectionDataSource(location: location, objectContext: objectContext)
        objectContext.perform {
            let name = location.name ?? ""
            DispatchQueue.main.async {
                self.setLabelHeading(name: name)
                self.PhotoCollection.reloadData()
            }
        }
    }
}

// MARK: FETCH CONTROLLER DELEGATE 

extension PhotoCollectionViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>){
        return
    }
    
}

// MARK: VC LIFE CYCLE

extension PhotoCollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCollectionView()
    }

    // MARK: SETUP HELPERS
    
    func setCollectionView(){
        PhotoCollection?.collectionViewLayout = cellLayout
        let containerWidth = view.frame.width
        let cellwidth = ((containerWidth/2) - 10)
        cellLayout.itemSize = CGSize.init(width: cellwidth, height: cellwidth)
    }
    
    func setLabelHeading(name:String){
        self.LocationName.text = name
    }
}

// MARK: COLLECTION VIEW DATA SOURCE

extension PhotoCollectionViewController: UICollectionViewDataSource {
    
    // apply default cells if no data exists in data source
    
    @objc func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        let n = photos?.collectionView(collectionView, numberOfItemsInSection: section) ?? 0
        return max(n,10)
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard
            let n = photos?.collectionView(collectionView, numberOfItemsInSection: indexPath.section),
            n > 0, // Some data exists
            indexPath.item < n // we are requesting for an index within bounds of array
        else {
            // Data doesn't exist and we're are returning a default cell
            return collectionView.dequeueReusableCell(withReuseIdentifier: "default", for: indexPath)
        }
        
        // return cell from data source
        return photos!.collectionView(collectionView, cellForItemAt: indexPath)
    }
}

