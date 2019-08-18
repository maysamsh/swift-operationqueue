//
//  ViewController.swift
//  Operations
//
//  Created by Maysam Shahsavari on 8/9/19.
//  Copyright © 2019 Maysam Shahsavari. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let activityIndicator = UIActivityIndicatorView(style: .gray)
    let pendingOperations = PendingOperations()
    var photos = [PhotoRecord]()
    var listOfImages = [URL]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        
        listOfImages.append(URL.init(string: "https://picsum.photos/id/1/500/500")!)
        listOfImages.append(URL.init(string: "https://picsum.photos/id/2/500/500")!)
        listOfImages.append(URL.init(string: "https://picsum.photos/id/3/500/500")!)
        listOfImages.append(URL.init(string: "https://picsum.photos/id/4/500/500")!)
        listOfImages.append(URL.init(string: "https://picsum.photos/id/5/500/500")!)
        listOfImages.append(URL.init(string: "https://picsum.photos/id/6/500/500")!)
        
        for item in listOfImages {
            let photo = PhotoRecord(url: item)
            photos.append(photo)
        }
        
        pendingOperations.downloadQueue.addObserver(self, forKeyPath: "operations", options: .new, context: nil)
        view.addSubview(activityIndicator)
        activityIndicator.frame = view.bounds
        activityIndicator.hidesWhenStopped = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        activityIndicator.center = view.center
    }
    
    func runQueues(){
        for (index, item) in self.photos.enumerated() {
            startOperations(for: item, at: index)
        }
    }
    
    func startOperations(for photoRecord: PhotoRecord, at index: Int) {
        switch (photoRecord.state) {
        case .new:
            startRetrieving(for: photoRecord, at: index)
        case .downloaded:
            startApplyingFilter(for: photoRecord, at: index)
        default:
            break
        }
    }
    
    func startRetrieving(for photoRecord: PhotoRecord, at index: Int) {
        guard pendingOperations.downloadInProgress[index] == nil else {
            return
        }
        
        let download = DownloadOperation(photoRecord)
        print("Operation Created \(photoRecord.url)")
        download.completionBlock = {
            if download.isCancelled {
                return
            }
            
            DispatchQueue.main.async {
                self.pendingOperations.downloadInProgress.removeValue(forKey: index)
            }
        }
        
        pendingOperations.downloadInProgress[index] = download
        pendingOperations.downloadQueue.addOperation(download)
        print("Operation Added \(photoRecord.url)")
    }
    
    func startApplyingFilter(for photoRecord: PhotoRecord, at index: Int){
        guard pendingOperations.filteringInProgress[index] == nil else {
            return
        }
        
        let filter = ImageFilterOperation(photoRecord)
        
        filter.completionBlock = {
            if filter.isCancelled {
                return
            }
            
            DispatchQueue.main.async {
                self.pendingOperations.filteringInProgress.removeValue(forKey: index)
            }
        }
        
        pendingOperations.filteringInProgress[index] = filter
        pendingOperations.filterQueue.addOperation(filter)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as? OperationQueue == pendingOperations.downloadQueue && keyPath == "operations" {
            if self.pendingOperations.downloadQueue.operations.isEmpty {
                pendingOperations.downloadQueue.removeObserver(self, forKeyPath: "operations")
                pendingOperations.filterQueue.addObserver(self, forKeyPath: "operations", options: .new, context: nil)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                self.runQueues()
            }
        }else if object as? OperationQueue == pendingOperations.filterQueue && keyPath == "operations" {
            if self.pendingOperations.filterQueue.operations.isEmpty {
                pendingOperations.filterQueue.removeObserver(self, forKeyPath: "operations")
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    @IBAction func download(_ sender: UIBarButtonItem) {
        activityIndicator.startAnimating()
        runQueues()
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let imageview = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let image = self.photos[indexPath.row].image
        imageview.image = image
        cell.contentView.addSubview(imageview)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}
