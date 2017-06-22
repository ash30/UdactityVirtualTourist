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


class PhotoCollectionViewController: UIViewController, ErrorFeedback {
    
    // MARK: PROPERTIES
    
    @IBOutlet weak var locationName: UILabel! {
        didSet{
            locationName.font = UIFont(name: "HelveticaNeue-UltraLight", size: 40.0)
            locationName.adjustsFontSizeToFitWidth = false
        }
    }
    @IBOutlet weak var photoCollection: UICollectionView! {
        didSet{
            photoCollection.dataSource = self
        }
    }
    @IBOutlet var cellLayout: UICollectionViewFlowLayout!
    var photos: LivePhotoData? {
        didSet{
            photos?.delegate = self
        }
    }
    @IBOutlet weak var refresh: UIBarButtonItem!
    
    var pendingPhotos: Int = 0 {
        didSet{
            if photoCollection != nil {
                photoCollection.reloadData()
            }
        }
    }
    
    @IBAction func refreshPhotos(_ sender: AnyObject) {
        
        // reset place holder cell number, but record existing
        // number incase we need to roll back 
        
        let currentPlaceHolder = pendingPhotos
        pendingPhotos = 10
        
        let result = photos?.replacePhotos()
        result?.then{ [weak self] _ in
           
            DispatchQueue.main.async {
                self?.pendingPhotos = 10
            }
            
        }
        .catch { [weak self] (err:Error) in
            print("Error Replacing Photos")
            print(err)
            DispatchQueue.main.async {
                self?.pendingPhotos = currentPlaceHolder // restore to prev
                self?.showErrorAlert(title: "Network Error", message: "Whoops! Can't refresh photos")
            }
        }
    }
}

// MARK: STORY BOARD INJECTION

extension PhotoCollectionViewController {
    
    func setupDependencies(basedOn location:TouristLocation, from objectContext:NSManagedObjectContext, creator:EntityFactory){
        
        photos = VT_PhotoCollectionDataSource(location: location, objectContext: objectContext, creator:creator)
        objectContext.perform {
            let name = location.name ?? "  "
            DispatchQueue.main.async {
                self.setLabelHeading(name: name)
                self.photoCollection.reloadData()
            }
        }
    }
}

// MARK: FETCH CONTROLLER DELEGATE 

extension PhotoCollectionViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>){
        photoCollection.reloadData()
    }
    
}

// MARK: VC LIFE CYCLE

extension PhotoCollectionViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoCollection?.collectionViewLayout = cellLayout
        setupCollectionCellSize(viewSize: view.frame.size)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        setupCollectionCellSize(viewSize: size)
    }

    // MARK: SETUP HELPERS
    
    func setupCollectionCellSize(viewSize: CGSize){
        
        if viewSize.height > viewSize.width {
            // Portrait Mode 
            let cellwidth = ((viewSize.width) - 20)
            cellLayout.itemSize = CGSize.init(width: cellwidth, height: cellwidth)
        }
        else {
            // Landscape
            let cellwidth = ((viewSize.width/5) - 10)
            cellLayout.itemSize = CGSize.init(width: cellwidth, height: cellwidth)
        }
    }
    
    func setLabelHeading(name:String){
        self.locationName.text = name
    }
}

// MARK: COLLECTION VIEW DATA SOURCE

extension PhotoCollectionViewController: UICollectionViewDataSource {
    
    // apply default cells if no data exists in data source
    
    @objc func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        let n = photos?.collectionView(collectionView, numberOfItemsInSection: section) ?? 0
        return max(n,pendingPhotos)
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard
            let n = photos?.collectionView(collectionView, numberOfItemsInSection: indexPath.section),
            n > 0, // Some data exists
            indexPath.item < n // we are requesting for an index within bounds of array
        else {
            // Data doesn't exist and we're are returning a default cell
            let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "default", for: indexPath) as! CollectionViewPlaceHolderCell
            cell.progress.startAnimating()
            return cell
            
        }
        
        // return cell from data source
        return photos!.collectionView(collectionView, cellForItemAt: indexPath)
    }
}

// MARK: COLLECTION VIEW DELEGATE 

extension PhotoCollectionViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        
        guard
            let n = photos?.collectionView(collectionView, numberOfItemsInSection: indexPath.section),            
            n >= indexPath.item + 1
        
            else {
                print("Not Removing place holder")
                return // No data OR its a place holder cell
        }
        
        if let result = photos?.removePhoto(index: indexPath), result == false {
            print ("Error removing Photo")
        }
        pendingPhotos -= 1
        
    }
    
}


