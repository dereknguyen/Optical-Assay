//
//  CameraViewController.swift
//  Assay Analysis
//
//  Created by Anthony Annuzzi on 12/1/15.
//  Copyright © 2015 CPE350 Capstone. All rights reserved.
//
//
// Old prototype class and probably unused but keeping for reference

import UIKit
import CoreMotion

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CameraOverlayDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var takePhotoBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var loadImgBtn: UIButton!
    @IBOutlet weak var pitchDataLabel: UILabel!
    @IBOutlet weak var rollDataLabel: UILabel!
    
    
    let motionManager = CMMotionManager();
    let imagePicker = UIImagePickerController();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main) { (data, error) in
            self.pitchDataLabel.text = "Pitch: " + String(data!.attitude.pitch);
            self.rollDataLabel.text = "Roll: " + String(data!.attitude.roll);
        }
        
        imagePicker.delegate = self;
        imageView.image = nil;
    }
    
    @IBAction func loadImageButtonTapped(_ sender: UIButton) {
        imagePicker.allowsEditing = false;
        imagePicker.sourceType = .photoLibrary;
        
        present(imagePicker, animated: true, completion: nil);
    }
    
    @IBAction func takePhotoButtonTapped(_ sender: UIButton) {
        let screenSize:CGSize = UIScreen.main.bounds.size
        
        let ratio:CGFloat = 4.0 / 3.0
        
        let width = min(screenSize.height, screenSize.width)
        let height = max(screenSize.height, screenSize.width)
        
        let cameraHeight:CGFloat = width * ratio
        let scale:CGFloat = height / cameraHeight
        
        imagePicker.allowsEditing = true;
        imagePicker.sourceType = .camera;
        imagePicker.isNavigationBarHidden = true;
        imagePicker.isToolbarHidden = true;
        
        
        imagePicker.cameraViewTransform = CGAffineTransform(translationX: 0, y: (height - cameraHeight) / 2.0)
        //        imagePicker.cameraViewTransform = CGAffineTransform(translationX: 0, y: (height - cameraHeight))
        imagePicker.cameraViewTransform = imagePicker.cameraViewTransform.scaledBy(x: scale, y: scale)
        //        imagePicker.cameraViewTransform = imagePicker.cameraViewTransform.scaledBy(x: 0, y: 0)
        
        imagePicker.showsCameraControls = false;
        
        let cameraOverlayVC = CameraOverlayViewController(nibName: "CameraOverlayViewController", bundle: nil);
        let cameraOverlay : CameraOverlayView = cameraOverlayVC.view as! CameraOverlayView
        
        cameraOverlay.frame = imagePicker.cameraOverlayView!.frame
        cameraOverlay.delegate = self
        
        self.imagePicker.cameraOverlayView = cameraOverlay;
        present(imagePicker, animated: true, completion: nil);
        
        //self.overlayView!.bounds = CGRect(x: 0, y: 0, width: width, height: height);
        //self.overlayView!.center = imagePicker.cameraOverlayView!.center;
        //self.overlayView!.center = CGPoint(x: height/2 , y: 475);
        //self.overlayView!.transform = CGAffineTransformRotate(CGAffineTransformIdentity, 117.81);
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit;
            imageView.image = pickedImage;
            nextBtn.isEnabled = true;
        }
        dismiss(animated: true, completion: nil);
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil);
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.identifier!) {
        case "toImageProcessing":
            NSLog("To image processing");
            motionManager.stopDeviceMotionUpdates()
            let vc = segue.destination as! DetectedCirclesViewController;
            vc.newImage = imageView.image;
        default:
            NSLog("error with segue");
        }
    }
    
    func didShoot(_ overlayView: CameraOverlayView) {
        // do nothing for now
        self.imagePicker.takePicture()
    }
    
    func didCancel(_ overlayView: CameraOverlayView) {
        // do nothing for now
        self.imagePicker.dismiss(animated: true, completion: nil)
    }
}
