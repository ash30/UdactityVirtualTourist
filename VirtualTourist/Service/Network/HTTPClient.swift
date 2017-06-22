//
//  NetworkController.swift
//  VirtualTourist
//
//  Created by Ashley Arthur on 11/12/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//

import Foundation
import PromiseKit


class HTTPClient {
    
    var connection: URLSession
    
    init( connection:URLSession){
        self.connection = connection
    }
    
    fileprivate func createTask(request:URLRequest) -> (URLSessionDataTask,Promise<Data>) {
    
        let promisedData = Promise<Data>.pending()
        
        let task = connection.dataTask(with: request){
            (data,response,error) in
            
            guard
                error == nil,
                let statusCode = (response as? HTTPURLResponse)?.statusCode
                else {
                    promisedData.reject(NetworkError.client(error!))
                    return
            }
            
            guard
                statusCode >= 200,
                statusCode <= 299,
                let data = data
                else {
                    promisedData.reject(NetworkError.server(statusCode))
                    return
            }
            
            // IF ALL LOOKS GOOD, RESOLVE WITH DATA
            promisedData.fulfill(data)
            
        }
        return (task, promisedData.promise)
    }

}

extension HTTPClient: NetworkController {
    
    private func submit(task:URLSessionDataTask, level: DispatchQoS.QoSClass = .background){
        DispatchQueue.global(qos: level).async {
            task.resume()
        }
    }
    
    // MARK: NETWORK MANAGER PROTOCOL
    
    func fetch(request:URLRequest) -> Promise<Data> {
        let (task, data) = createTask(request: request)
        submit(task: task, level: .userInitiated)
        return data
    }
    
    func prefetch(request:URLRequest) -> Promise<Data> {
        let (task, data) = createTask(request: request)
        submit(task: task, level: .background)
        return data
    }
    

}
