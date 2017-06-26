//
//  MapViewDetailPresentationController.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 26/06/2017.
//  Copyright © 2017 AshArthur. All rights reserved.
//

import UIKit

class MapViewDetailPresentationController: UIPresentationController, UIGestureRecognizerDelegate {
    
    lazy var panningDismissGesture: UIPanGestureRecognizer  = {
        let gesture = UIPanGestureRecognizer.init(target: self, action: #selector(dismissPresented))
        return gesture
    }()
    
    lazy var tapDsmissGesture: UITapGestureRecognizer  = {
        let gesture = UITapGestureRecognizer.init(target: self, action: #selector(dismissPresented))
        gesture.delegate = self
        return gesture
    }()
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // For tap to dismiss, only action if user selects presenting view (e.g backdrop map)
        if let view = touch.view, let container = containerView {
            return view == container
        }
        return false
    }
    
    override var frameOfPresentedViewInContainerView: CGRect{
        let height: CGFloat = containerView!.frame.height / 3.0
        
        return CGRect(x: 0, y: containerView!.frame.height - height, width: containerView!.frame.width, height: height)
    }
    
    override func containerViewDidLayoutSubviews(){
        presentedViewController.viewIfLoaded?.addGestureRecognizer(panningDismissGesture)
        containerView?.addGestureRecognizer(tapDsmissGesture)
    }
    
    // Helpers
    
    func dismissPresented(){
        presentedViewController.dismiss(animated: true) {
        }
    }

    
}
