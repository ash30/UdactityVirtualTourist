//
//  Networking.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 06/12/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//

import Foundation

// MARK: NETWORK ERRORS

enum NetworkError: Error  {
    case client(Error)
    case server(Int)
}

// MARK: NETWORK MANAGER

protocol NetworkManager {
    
    func submit(networkTask:URLSessionDataTask, level: DispatchQoS.QoSClass)
    
}

extension NetworkManager {
    
    func submit(networkTask:URLSessionDataTask, level: DispatchQoS.QoSClass) {
        DispatchQueue.global(qos: .background).async {
            networkTask.resume()
        }
    }
    
}

// MARK: HTTP CLIENT

protocol HTTPClient {
    
    var connection: URLSession { get }
    var network: NetworkManager { get }

    func send(request:URLRequest) -> Promise<Data>
    func prefetch(request:URLRequest) -> Promise<Data>
    
}

extension HTTPClient {
 
    func send(request:URLRequest) -> Promise<Data> {
        let (task, data) = CreateTask(request: request)
        network.submit(networkTask: task, level: .userInitiated)
        return data
    }
    
    func prefetch(request:URLRequest) -> Promise<Data> {
        let (task, data) = CreateTask(request: request)
        network.submit(networkTask: task, level: .background)
        return data
    }
    
    func CreateTask(request:URLRequest) -> (URLSessionDataTask,Promise<Data>) {
        let promisedData = Promise<Data>()
        let task = connection.dataTask(with: request){
            (data,response,error) in
            
            guard
                error == nil,
                let statusCode = (response as? HTTPURLResponse)?.statusCode
                else {
                    promisedData.reject(error: NetworkError.client(error!))
                    return
            }
            
            guard
                statusCode >= 200,
                statusCode <= 299,
                let data = data
                else {
                    promisedData.reject(error: NetworkError.server(statusCode))
                    return
            }
            
            // IF ALL LOOKS GOOD, RESOLVE WITH DATA
            promisedData.resolve(value: data)
            
        }
        return (task, promisedData)
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
    

