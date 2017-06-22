//
//  Networking.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 06/12/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//

import Foundation
import PromiseKit

// MARK: NETWORK ERRORS

enum NetworkError: Error  {
    case client(Error)
    case server(Int)
}

// MARK: NETWORK CONTROLLER

protocol NetworkController {
    
    func fetch(request:URLRequest) -> Promise<Data>
    func prefetch(request:URLRequest) -> Promise<Data>
    
}


    

