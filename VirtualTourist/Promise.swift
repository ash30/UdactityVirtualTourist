//
//  Promise.swift
//  OnTheMap
//
//  Created by Ashley Arthur on 13/10/2016.
//  Copyright © 2016 AshArthur. All rights reserved.
//
// NOTES:
// Realise - the promise callback will execute in the same thread as
// the resolver of promise
// E.G if async resolve, the callbacks will also happen on the worker thread

import Foundation

enum PromiseError: Error {
    case CallbackError
}

enum PromiseState<T>: Equatable {
    case PENDING
    case REJECTED (error:Error)
    case SUCCESS (value:T)
    
    // We just want simple hashValue base equality but since we define assoicated values
    // we need to define our own implementation
    static func ==(lhs: PromiseState<T>, rhs: PromiseState<T>) -> Bool{
        switch (lhs,rhs){
        case (.PENDING, .PENDING):  return true
        case (.REJECTED, .REJECTED):return true
        case (.SUCCESS, .SUCCESS):  return true
        default:return false
        }
    }
}

class Promise<T> {
    
    // MARK: CALLBACKS
    typealias successCallback = (T) -> Void
    typealias rejectCallback = (Error) -> Void
    
    // Automatically call callback in promise is already resolved/rejected
    var onSuccessCallbacks: [successCallback] = [] {
        didSet{
            switch currentState{
            case .SUCCESS:
                if onSuccessCallbacks.count > 0 {execute()}
            default:
                return
            }
        }
    }
    var onRejectCallbacks: [rejectCallback] = [] {
        didSet{
            switch currentState{
            case .REJECTED:
                if onRejectCallbacks.count > 0 {execute()}
            default:
                return
            }
        }
    }
    
    func execute(){
        switch currentState {
        case .SUCCESS( let value):
            let _ = onSuccessCallbacks.map{ callback in
                callback(value)
            }
        case .REJECTED(let error):
            let _ = onRejectCallbacks.map{ callback in
                callback(error)
            }
        case .PENDING:
            return // Can't excute if not resolve
        }
        // FINALLY CLEAR ALL CALLBACKS
        onRejectCallbacks = []; onSuccessCallbacks = []
    }
    
    
    // PROMISE STATE
    var currentState: PromiseState<T> = .PENDING {
        didSet{
            // If state switches to NON PENDING, execute()
            switch currentState {
            case .PENDING:
                return
            default:
                execute()
            }
        }
    }
    // ONLY allow to transition when promise is pending
    func transition (to state:PromiseState<T>){
        switch currentState{
        case .REJECTED, .SUCCESS:
        return // Can't resolve already resolved!
        case .PENDING:
            break // Continue
        }
        currentState = state
    }
    
    
    // MARK: PUBLIC
    func resolve(value:T){
        transition(to: .SUCCESS(value: value))
    }
    func reject (error:Error){
        currentState  = .REJECTED(error: error)
    }
}

// MARK: THEN IMPLEMENTATIONS
extension Promise{
    
    // IF CALLBACK RETURNS NOTHING, WE DON'T CARE ABOUT NEW PROMISE REALLY HENCE NO RETURN
    func then(onSuccess:((T) -> Void)?,onReject:rejectCallback?) -> Void {
        if let callback = onSuccess{
            onSuccessCallbacks.append(callback)
        }
        if let callback = onReject {
            onRejectCallbacks.append(callback)
        }
    }
    
    // RETURN PROMISE THAT RESOLVES WHEN THIS PROMISE DOES + WITH VAL OF CALLBACK
    func then<U>(onSuccess:((T) throws ->U)?, onReject:rejectCallback?) -> Promise<U> {
        
        // MAKE NEW PROMISE
        let p = Promise<U>()
        
        // EXTEND SUCCESS CALLBACK TO ALSO RESOLVE NEW PROMISE WITH RETURN
        if let callback = onSuccess{
            onSuccessCallbacks.append({ (val:T) -> Void in
                
                do{
                    let newVal:U = try callback(val)
                    p.resolve(value: newVal)
                }
                catch{
                    p.reject(error: error)
                }
            })
        }
        
        // IF REJECT CALLBACK, EXECUTE IT FIRST BEFORE REJECTING NEW PROMISE
        if let callback = onReject{
            onRejectCallbacks.append({ err in
                callback(err);p.reject(error: err)
            })
        }
        else {
            onRejectCallbacks.append({ err in
                p.reject(error: err)
            })
        }
        return p
    }
    
    // IF CALLBACK RETURNS PROMISE, WAIT FOR PROMISE TO RESOLVE AND THEN RESOLVE NEW PROMISE
    func then<U>(onSuccess:@escaping (T) throws ->Promise<U>) -> Promise<U>{
        
        let p = Promise<U>()
        
        onSuccessCallbacks.append({ (val:T) -> Void in
            
            // WHEN CALLBACK FIRES, LINK RETURN PROMISE
            do {
                let callbackPromise: Promise<U> = try onSuccess(val)
                
                callbackPromise.then(
                    onSuccess: { (val:U) -> Void  in
                        p.resolve(value: val)
                    },
                    onReject: { err in
                        p.reject(error: err)
                    }
                )
            }
            catch {
                // IF CALLBACK THROWS, REJECT NEW PROMISE
                p.reject(error: error)
            }
        })
        
        // IF ORIGINAL PROMISE FAILS, REJECT NEW PROMISE
        onRejectCallbacks.append({ err in
            p.reject(error: err)
        })
        
        return p
    }
    
}



