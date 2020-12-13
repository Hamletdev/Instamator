//
//  SelectPhotoViewController.swift
//  Instamator
//
//  Created by Amit Chaudhary on 12/13/20.
//  Copyright © 2020 Amit Chaudhary. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import Photos

fileprivate let reuseIdentifier = "SelectPhotoCell"
fileprivate let headerIdentifier = "SelectHeaderCell"

class SelectPhotoViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var photos = [UIImage]()
    var assets = [PHAsset]()
    
    var selectedImage: UIImage?
    
    var header: SelectPhotoHeaderView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.constructNavigationBarButton()
        self.fetchPhotos()
        
        self.collectionView.register(SelectPhotoCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView.register(SelectPhotoHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        view.backgroundColor = .white
        
    }
    
    //MARK: - UICollectionView Data Source
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SelectPhotoCell
        cell.photoImageView.image = photos[indexPath.row]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = self.collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! SelectPhotoHeaderView
//        header.photoImageView.image = self.selectedImage  //made a bad resolution
        
        //make resolution better
        self.header = header
        if let safeSelectedimage = self.selectedImage {
            
        if let index = self.photos.firstIndex(of: safeSelectedimage) {
            let selectedAsset = self.assets[index]
            let imageManager = PHImageManager.default()
            let targetSize = CGSize(width: 600, height: 600)
            imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .aspectFit, options: PHImageRequestOptions()) { (image, info) in
                header.photoImageView.image = image
            }
        }
        }
        return header
    }
    
    
    //MARK: - UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedImage = photos[indexPath.row]
        self.collectionView.reloadData()
        
        //scroll collection to first item of first section
        let indexPath = IndexPath(item: 0, section: 0)
        self.collectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.bottom, animated: true)
    }
    
    
    //MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = self.view.frame.width
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    
}

//MARK: - Extra Methods
extension SelectPhotoViewController {
    func constructNavigationBarButton() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleNextPressed))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(handleCancelPressed))
    }
    
    @objc func handleCancelPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleNextPressed() {
        let uploadVC = UploadPostViewController()
        uploadVC.postImage = self.selectedImage
        self.navigationController?.pushViewController(uploadVC, animated: true)
    }
}

//MARK: - Fetch Photos
extension SelectPhotoViewController {
    func getAssetFetchOptions() -> PHFetchOptions {
        let options = PHFetchOptions()
        options.fetchLimit = 40
        let sortDescriptors = NSSortDescriptor(key: "creationDate", ascending: false)
        options.sortDescriptors = [sortDescriptors]
        return options
    }
    
    func fetchPhotos() {
        let allPhotos = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: self.getAssetFetchOptions())
        //fetch photos in background mode
        DispatchQueue.global(qos: .background).async {
            allPhotos.enumerateObjects { (asset, count, stop) in
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 209, height: 209)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: PHImageContentMode.aspectFit, options: options) { (image, info) in
                    if let safePhoto = image {
                        self.photos.append(safePhoto)
                        self.assets.append(asset)
                        if self.selectedImage == nil {
                            self.selectedImage = safePhoto
                        }
                        if count == allPhotos.count - 1 {
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
}
