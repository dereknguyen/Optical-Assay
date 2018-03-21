//
//  NewAnalysisViewController.swift
//  Assay Analysis
//
//  Created by Anthony Annuzzi on 1/14/16.
//  Copyright © 2016 CPE350 Capstone. All rights reserved.
//
//  Displays the form for adding a new analysis and handles the
//  image selection from the camera or library
//

import Foundation
import UIKit

class NewAnalysisViewController : UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CameraOverlayDelegate {
    
    
    @IBOutlet weak var nameTextView: FloatLabelTextField!
    @IBOutlet weak var descTextView: FloatLabelTextView!
    @IBOutlet weak var analysisImage: UIImageView!
    
    private var currentImage = UIImage()
    
    var chosenImage : UIImage! = nil
    let imagePicker = UIImagePickerController()
    
    
    var wellplateWidth: CGFloat!
    var wellplateLength: CGFloat!
    var wellSpacing: CGFloat!
    var wellRadius: CGFloat!
    
    let cameraOverlayVC = CameraOverlayViewController(nibName: "CameraOverlayViewController", bundle: nil);
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.setToolbarHidden(true, animated: false)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let singleTap = UITapGestureRecognizer(target: self, action:#selector(NewAnalysisViewController.tapDetected(_:)))
        singleTap.numberOfTapsRequired = 1
        analysisImage.isUserInteractionEnabled = true
        analysisImage.addGestureRecognizer(singleTap)
        
        navigationItem.largeTitleDisplayMode = .automatic
        
        
        imagePicker.delegate = self;
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
//        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(doneEditing))
        let doneButton = UIBarButtonItem(title: "Hide Keyboard", style: UIBarButtonItemStyle.done, target: self, action: #selector(doneEditing))
        toolBar.setItems([doneButton], animated: false)
        
        
        nameTextView.inputAccessoryView = toolBar
        descTextView.inputAccessoryView = toolBar
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
        
        navigationController?.setToolbarHidden(true, animated: false)
    }

    func doneEditing() {
        self.view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func tapDetected(_ img: AnyObject?) {

//        let addPictureActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
//        let cameraButton = UIAlertAction(title: "Camera", style: UIAlertActionStyle.destructive) { (action) in
            let hasCamera = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
            if hasCamera {
                self.launchCamera()
            }
            else {
                NSLog("Camera unavailable")
            }
//        }
    
    
//        let photoLibraryButton = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.default) { (action) in
//            self.pickFromLibrary()
//        }
//        let cancelButton = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) in
//            NSLog("Cancel Pick")
//        }
    
//        addPictureActionSheet.addAction(cameraButton)
////        addPictureActionSheet.addAction(photoLibraryButton)
//        addPictureActionSheet.addAction(cancelButton)
    
//        present(addPictureActionSheet, animated: true, completion: nil)

    }
    
    func launchCamera() {
        let screenSize : CGSize = UIScreen.main.bounds.size
        let ratio : CGFloat = 4.0 / 3.0

        let width = min(screenSize.height, screenSize.width)
        let height = max(screenSize.height, screenSize.width)
        let cameraHeight : CGFloat = width * ratio


        imagePicker.allowsEditing = false;
        imagePicker.sourceType = .camera;
        imagePicker.isNavigationBarHidden = true;
        imagePicker.isToolbarHidden = true;
        imagePicker.modalPresentationStyle = .currentContext
        
        
        
        imagePicker.cameraCaptureMode = .photo
        imagePicker.videoQuality = .typeHigh
        imagePicker.cameraViewTransform = CGAffineTransform(translationX: 0, y: (height - cameraHeight) / 2.0)
        imagePicker.cameraViewTransform = imagePicker.cameraViewTransform.scaledBy(x: 1, y: 1)

        
        imagePicker.showsCameraControls = false;
        imagePicker.allowsEditing = false
        imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.rear
        
        let cameraOverlay : CameraOverlayView = cameraOverlayVC.view as! CameraOverlayView
        cameraOverlay.frame = imagePicker.cameraOverlayView!.frame
        cameraOverlay.delegate = self
        
        
        self.imagePicker.cameraOverlayView = cameraOverlay;
        present(imagePicker, animated: true, completion: nil);
    }
    
    func pickFromLibrary() {
        imagePicker.allowsEditing = false;
        imagePicker.sourceType = .photoLibrary;
        
        present(imagePicker, animated: true, completion: nil);
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            chosenImage = UIImage(cgImage: pickedImage.cgImage!, scale: 1.0, orientation: UIImageOrientation.up)
        
            
            analysisImage.contentMode = .scaleAspectFit;
            analysisImage.image = chosenImage
            
            
            if (picker.sourceType == .camera) {
               
                print("Save image")
                AssayAnalysisPhotoAlbum.sharedInstance.saveImage(chosenImage)
            } else {
                AssayAnalysisPhotoAlbum.sharedInstance.saveImage(chosenImage)
            }
        }
        dismiss(animated: true, completion: nil);
    }
    
    
    
//    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
//        if let error = error {
//            // we got back an error!
//            print(error)
//            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
//            ac.addAction(UIAlertAction(title: "OK", style: .default))
//            present(ac, animated: true)
//        } else {
//            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
//            ac.addAction(UIAlertAction(title: "OK", style: .default))
//            present(ac, animated: true)
//        }
//    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil);
    }
    
    func didShoot(_ overlayView: CameraOverlayView) {
        self.imagePicker.takePicture()
        self.wellplateWidth = self.cameraOverlayVC.wellPlateWidth_px
        self.wellplateLength = self.cameraOverlayVC.wellPlateLength_px
        self.wellSpacing = self.cameraOverlayVC.wellDistance_px
        self.wellRadius = self.cameraOverlayVC.wellRadius_px
    }
    
    func didCancel(_ overlayView: CameraOverlayView) {
        self.imagePicker.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.identifier!) {
        case "toImageProcessing":
            let vc = segue.destination as! DetectedCirclesViewController;
            vc.newImage = chosenImage;
            vc.name = nameTextView.text
            vc.desc = descTextView.text
            if let wellplateWidth = self.wellplateWidth {
                vc.wellplateWidth = wellplateWidth
                vc.wellplateLength = self.wellplateLength
                vc.wellSpacing = self.wellSpacing
                vc.wellRadius = self.wellRadius
            }
        default:
            NSLog("error with segue");
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == "toImageProcessing") {
            if (chosenImage == nil) {
                let alert = UIAlertController(title: "No Image", message: "Please select an image", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return false
            }
            
            if let name = nameTextView.text {
            
                if (name.isEmpty) {
                    let alert = UIAlertController(title: "No Name", message: "Please enter a name", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return false
                }
            }
        }
        return true
    }
    
    
    
    func keyboardWillShow(notification: NSNotification) {

        if let image = analysisImage.image {
            currentImage = image
        }
        
        analysisImage.image = nil
        analysisImage.isHidden = true

    }
    
    func keyboardWillHide(notification: NSNotification) {
        analysisImage.image = currentImage
        analysisImage.isHidden = false
    }
    
    
    
}
