//
//  CollectionViewPlaceholderCell.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 13/12/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//

import Foundation
import UIKit

class CollectionViewPlaceHolderCell: UICollectionViewCell {
    
    @IBOutlet weak var progress: UIActivityIndicatorView! {
        didSet{
            progress.startAnimating()
        }
    }
}
