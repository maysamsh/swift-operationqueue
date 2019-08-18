//
//  PhotoRecord.swift
//  Operations
//
//  Created by Maysam Shahsavari on 8/9/19.
//  Copyright © 2019 Maysam Shahsavari. All rights reserved.
//

import Foundation
import UIKit

class PhotoRecord {
    let url: URL
    var image: UIImage? = nil
    var state = OperationState.new
    
    init(url: URL) {
        self.url = url
    }
}
