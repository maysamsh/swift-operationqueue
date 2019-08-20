//
//  AyncOperation.swift
//  Operations
//
//  Created by Maysam Shahsavari on 8/9/19.
//  Copyright © 2019 Maysam Shahsavari. All rights reserved.
//

import Foundation

class AsyncOperation: Operation {
    override var isAsynchronous: Bool {
        return true
    }
    
    private let _queue = DispatchQueue(label: "asyncOperationQueue", attributes: .concurrent)
    private var _isExecuting: Bool = false
    
    override var isExecuting: Bool {
        set {
            willChangeValue(forKey: "isExecuting")
            _queue.async(flags: .barrier) {
                self._isExecuting = newValue
            }
            didChangeValue(forKey: "isExecuting")
        }
        
        get {
            return _isExecuting
        }
    }
    
    var _isFinished: Bool = false
    
    override var isFinished: Bool {
        set {
            willChangeValue(forKey: "isFinished")
            _queue.async(flags: .barrier) {
                self._isFinished = newValue
            }
            didChangeValue(forKey: "isFinished")
        }
        
        get {
            return _isFinished
        }
    }
}
