//
//  PendingOperation.swift
//  Operations
//
//  Created by Maysam Shahsavari on 8/9/19.
//  Copyright © 2019 Maysam Shahsavari. All rights reserved.
//

import Foundation

class PendingOperations {
    lazy var downloadInProgress: [Int: Operation] = [:]
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Download Queue"
        return queue
    }()
    
    lazy var filteringInProgress: [Int: Operation] = [:]
    lazy var filterQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "Filter Queue"
        return queue
    }()
}
