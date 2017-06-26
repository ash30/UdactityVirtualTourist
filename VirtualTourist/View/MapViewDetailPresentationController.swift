//
//  MapViewDetailPresentationController.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 26/06/2017.
//  Copyright © 2017 AshArthur. All rights reserved.
//

import UIKit

class MapViewDetailPresentationController: UIPresentationController {

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: frameOfPresentedViewInContainerView.size, with: coordinator)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect{
        let height: CGFloat = containerView!.frame.height / 3.0
        
        return CGRect(x: 0, y: containerView!.frame.height - height, width: containerView!.frame.width, height: height)
    }

    
}
