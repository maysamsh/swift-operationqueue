//
//  Operations.swift
//  Operations
//
//  Created by Maysam Shahsavari on 8/9/19.
//  Copyright © 2019 Maysam Shahsavari. All rights reserved.
//

import Foundation
import UIKit

class DownloadOperation: AsyncOperation {
    let photoRecord: PhotoRecord
    
    init(_ photoRecord: PhotoRecord) {
        self.photoRecord = photoRecord
    }
    
    override func main() {
        if isCancelled {
            return
        }
        
        isExecuting = true
        isFinished = false
        print("Operation Started \(self.photoRecord.url)")
        downloader(url: photoRecord.url) { (result) in
            
            switch result {
            case .failure:
                self.photoRecord.state = .failed
            case .success(let image):
                self.photoRecord.state = .downloaded
                self.photoRecord.image = image
            }
            
            self.isExecuting = false
            self.isFinished = true
        }
    }
}

class ImageFilterOperation: AsyncOperation {
    let photoRecord: PhotoRecord
    
    init(_ photoRecord: PhotoRecord) {
        self.photoRecord = photoRecord
    }
    
    override func main() {
        if isCancelled {
            return
        }
        
        isExecuting = true
        isFinished = false
        
        guard let currentCGImage = photoRecord.image?.cgImage else {
            self.photoRecord.state = .failed
            self.isExecuting = false
            self.isFinished = true
            return
        }
        
        let currentCIImage = CIImage(cgImage: currentCGImage)
        
        let filter = CIFilter(name: "CIColorMonochrome")
        filter?.setValue(currentCIImage, forKey: "inputImage")
        
        filter?.setValue(CIColor(red: 0.65, green: 0.65, blue: 0.65), forKey: "inputColor")
        
        filter?.setValue(1.0, forKey: "inputIntensity")
        guard let outputImage = filter?.outputImage else { return }
        
        let ciContext = CIContext()
        
        if let cgimg = ciContext.createCGImage(outputImage, from: outputImage.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            self.photoRecord.image = processedImage
            self.photoRecord.state = .filtered
            self.isExecuting = false
            self.isFinished = true
        }else{
            self.photoRecord.state = .failed
            self.isExecuting = false
            self.isFinished = true
        }
    }
}

extension DownloadOperation {
    func downloader(url: URL, completion: @escaping (Swift.Result<UIImage?, Error>)->()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let httpURLResponse = response as? HTTPURLResponse {
                if httpURLResponse.statusCode == 200 {
                    if let _data = data {
                        completion(.success(UIImage.init(data: _data)))
                    }else{
                        completion(.failure(DownloadError.invalidImage))
                    }
                }
            }else{
                completion(.failure(DownloadError.networkError))
            }
        }.resume()
    }
    
}
