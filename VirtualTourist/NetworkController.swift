//
//  NetworkController.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 11/12/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//

import Foundation


class NetworkController: NetworkManager, HTTPClient {
    
    var network: NetworkManager {
        return self
    }
    
    var connection: URLSession
    
    init( connection:URLSession){
        self.connection = connection
    }
    
}
