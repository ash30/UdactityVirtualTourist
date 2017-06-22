//
//  NetworkServices.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 11/12/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//

import Foundation

// MARK: HTTP SERVICES

protocol RawRepresentableAsString {
    var rawValue: String { get }
}

protocol ResourceServerDetails {
    associatedtype Path:RawRepresentableAsString
    var scheme : String { get }
    var host: String { get }
    
    func url(forResource path:Path) -> NSURLComponents
}

extension ResourceServerDetails  {
    func url(forResource path:Path) -> NSURLComponents {
        let components = NSURLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path.rawValue
        return components
    }
}

// MARK: SERVICE CLIENT

protocol ServiceClient {
}

extension ServiceClient {
    
    func decodeJson(_ data:Data, jsonBuffering:Int?) -> [String:Any]?{
        let truncated: Data = data.subdata(in: (jsonBuffering ?? 0)..<data.count)
        guard
            let json = (try? JSONSerialization.jsonObject(
                with: truncated, options: .allowFragments)) as? [String:Any]
            else {
                return nil
        }
        return json
        
    }
}
