//
//  MapViewTransitionDelegate.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 26/06/2017.
//  Copyright © 2017 AshArthur. All rights reserved.
//

import Foundation
import UIKit


class MapViewTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        return MapViewDetailPresentationController(presentedViewController: presented, presenting: presenting)
        
    }
    
    
}
