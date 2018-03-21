//
//  CameraOverlayView.swift
//  Assay Analysis
//
//  Created by Anthony Annuzzi on 1/8/16.
//  Copyright © 2016 CPE350 Capstone. All rights reserved.
//

import UIKit

protocol CameraOverlayDelegate {
    func didCancel(_ overlayView : CameraOverlayView)
    func didShoot(_ overlayView : CameraOverlayView)
}

class CameraOverlayView : UIView {
    var delegate : CameraOverlayDelegate! = nil;
    
    
    @IBAction func takePhoto(_ sender: AnyObject) {
        delegate.didShoot(self)
    }
    
    
    @IBAction func cancelPhoto(_ sender: AnyObject) {
        delegate.didCancel(self)
    }
    
}
