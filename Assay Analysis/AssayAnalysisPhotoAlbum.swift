//
//  AssayAnalysisPhotoAlbum.swift
//  Assay Analysis
//
//  Created by Anthony Annuzzi on 2/20/16.
//  Copyright © 2016 CPE350 Capstone. All rights reserved.
//

import Foundation
import Photos

class AssayAnalysisPhotoAlbum : NSObject {
    
    static let albumName = "Assay Analysis"
    static let sharedInstance = AssayAnalysisPhotoAlbum()
    
    var assetCollection : PHAssetCollection!
    
    override init() {
        super.init()
        
        if let assetCollection = fetchAssetCollectionForAlbum() {
            self.assetCollection = assetCollection
            return
        }
        
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({
                (status : PHAuthorizationStatus) -> Void in status
            })
        }
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            self.createAlbum()
        } else {
            PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
        }
    }
    
    func requestAuthorizationHandler(_ status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            print("trying to create the album")
            self.createAlbum()
        } else {
            print("failed create")
        }
    }
    
    func createAlbum() {
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: AssayAnalysisPhotoAlbum.albumName)   // create an asset collection with the album name
            }) { success, error in
                if success {
                    self.assetCollection = self.fetchAssetCollectionForAlbum()
                } else {
                    print("error \(String(describing: error))")
                }
        }
    }
    
    func fetchAssetCollectionForAlbum() -> PHAssetCollection! {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", AssayAnalysisPhotoAlbum.albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject as! PHAssetCollection
        }
        return nil
    }
    
    
    
    func saveImage(_ image: UIImage) {
        if assetCollection == nil {
            return                          // if there was an error upstream, skip the save
        }
        
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            albumChangeRequest!.addAssets([assetPlaceHolder!] as NSArray)
            }, completionHandler: nil)
    }
    
    func tagImage(_ info : [String : AnyObject]) {
        if assetCollection == nil {
            return
        }
        
        if (info["UIImagePickerControllerMediaType"] as! String == "public.image") {
            print("Photo")
            // Photo
            let res = PHAsset.fetchAssets(withALAssetURLs: [info["UIImagePickerControllerReferenceURL"] as! URL], options: nil)
            
            let asset = res.lastObject!
            
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetCollectionChangeRequest(for: self.assetCollection);
                request?.addAssets([asset] as NSArray);
                }, completionHandler: nil);
        }
    }
    
    
}
