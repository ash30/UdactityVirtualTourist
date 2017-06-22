//
//  ErrorReporting.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 13/12/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//

import Foundation
import UIKit

// Trait for controllers to alert users of errors
protocol ErrorFeedback {
}

extension ErrorFeedback where Self:UIViewController
{
    func showErrorAlert(title:String, message:String){
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        vc.addAction(
            UIAlertAction(
                title: "Ok",
                style:.default,
                handler: {_ in self.dismiss(animated: true, completion: nil)}
        ))
        present(vc, animated: true){
        }
    }
}
