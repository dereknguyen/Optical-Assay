 //
//  CameraOverlayViewController.swift
//  Assay Analysis
//
//  Created by Anthony Annuzzi on 1/8/16.
//  Copyright © 2016 CPE350 Capstone. All rights reserved.
//

import UIKit
import AVFoundation
 
class CameraOverlayViewController: UIViewController {


    var guideHeight = CGFloat()
    var guideWidth = CGFloat()
    
    var wellDistancePixel = CGFloat()
    var wellRadiusPixel = CGFloat()
    
    let iPhoneXImageWidth_px: CGFloat = 2448.0
    let iPhoneXImageLength_px: CGFloat = 3264.0
    
    let wellPlateWidth_mm: CGFloat = 85.0
    let wellPlateLength_mm: CGFloat = 127.5
    let wellDistance_mm: CGFloat = 9.0
    var wellRadius_mm: CGFloat = 6.96 / 2
    
    var wellPlateWidth_px = CGFloat()
    var wellPlateLength_px = CGFloat()
    var wellDistance_px = CGFloat()
    var wellRadius_px = CGFloat()
    
    @IBOutlet weak var widthContstraint: NSLayoutConstraint!
    
    @IBOutlet weak var guideline: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.guideHeight = guideline.bounds.height
        self.guideWidth = guideline.bounds.width
        
        
        self.wellPlateWidth_px = iPhoneXImageWidth_px * widthContstraint.multiplier
        self.wellPlateLength_px = wellPlateWidth_px * (wellPlateLength_mm / wellPlateWidth_mm)
        
        self.wellPlateWidth_px -= 100
        self.wellPlateLength_px -= 100
        self.wellDistance_px = wellPlateLength_px * (wellDistance_mm / wellPlateLength_mm)
        self.wellRadius_px = wellPlateLength_px * (wellRadius_mm / wellPlateLength_mm)
        
        print("Multiplier", self.widthContstraint.multiplier)
        print("px: Wellplate width", wellPlateWidth_px)
        print("px: Wellplate length", wellPlateLength_px)
        print("px: Well distance", wellDistance_px)
        print("px: Well radius", wellRadius_px)
        
        print("Leght / width:", wellPlateLength_px / wellPlateWidth_px)
        print("Length / distance:", wellPlateLength_px / wellDistance_px)
        print("Length / radius:", wellPlateLength_px / wellRadius_px)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
