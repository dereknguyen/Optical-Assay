//
//  Utils.swift
//  Assay Analysis
//
//  Created by Anthony Annuzzi on 1/25/16.
//  Copyright © 2016 CPE350 Capstone. All rights reserved.
//

import Foundation

class Utils {
    
    static func deleteImages(_ name : String) {
        deleteImage(name)
        deleteImageThumbnail(name)
    }
    
    static fileprivate func deleteImage(_ name : String) -> Bool{
        let fileName = getDocumentsDirectory().appendingPathComponent(name + ".png")
        do {
            try FileManager.default.removeItem(atPath: fileName)
            return true
        } catch {
            print(error)
        }
        return false
    }
    
    static fileprivate func deleteImageThumbnail(_ name : String) -> Bool {
        return deleteImage(name + "_thumb")
    }
    
    static func saveImages(_ image : UIImage, name : String) {
        saveImage(image, name:name)
        saveThumbnail(image, name:name)
    }
    
    static fileprivate func saveImage(_ image : UIImage, name : String) -> Bool {
        if let data = UIImageJPEGRepresentation(image, 1.0) {
            let fileName = getDocumentsDirectory().appendingPathComponent(name + ".png")
            return ((try? data.write(to: URL(fileURLWithPath: String(fileName)), options: [.atomic])) != nil)
        }
        return false
    }
    
    static fileprivate func saveThumbnail(_ image : UIImage, name : String) -> Bool {
        let scale = 120 / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: 120, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: 120, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return saveImage(newImage!, name: name + "_thumb")
    }
    
    static func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory as NSString
    }
    
    static func getCurrentMillis()->Int64{
        return  Int64(Date().timeIntervalSince1970 * 1000)
    }
}
