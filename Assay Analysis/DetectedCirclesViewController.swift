//
//  ViewController.swift
//  Assay Analysis
//
//  Created by Anthony Annuzzi on 10/1/15.
//  Copyright (c) 2015 CPE350 Capstone. All rights reserved.
//
// This class is used to display the circles detected from the user's image
// from here they can tap and we will detect/add a circle near the point they
// tapped. For now, an alert will be displayed every time this screen is viewed
// so that they know what to do on this screen.

import CoreData
import UIKit
import JGProgressHUD

class DetectedCirclesViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var analysisDesc: UITextView!
    @IBOutlet weak var testName: UILabel!
    
    
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    let segmentControl = UISegmentedControl(items: ["Add Circles", "Delete Circles"])
    
    enum Mode {
        case add;
        case delete;
    }
    
    var detectedCircles : CirclePosition! = nil
    var drawnCircleDict : NSMutableDictionary! = nil
    var imageView : UIImageView!
    
    var circleDetectedImage : UIImage! = nil
    var newImage : UIImage! = nil
    var name : String!
    var desc : String!
    
    var wellplateWidth: CGFloat!
    var wellplateLength: CGFloat!
    var wellSpacing: CGFloat!
    var wellRadius: CGFloat!
    

    
    var lastZoomScale : CGFloat = -1
    
    var hud : JGProgressHUD!
    
    var mode : Mode = .add;
    //var temp


    @IBAction func switchToMode(_ sender: UIButton) {
        if sender.tag == 0 {
            mode = .add;
        } else {
            mode = .delete;
        }
        setEditMode();
    }
    
    func detectCircles() {
        showProgressBar("Detecting wells")
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
        
            if let plateWidth = self.wellplateWidth {
                print("Height", self.newImage.size.height)
                print("Width", self.newImage.size.width)
                self.detectedCircles = OpenCVWrapper.detectCircles(self.newImage, wellplateWidth: Double(plateWidth), wellplateLength: Double(self.wellplateLength), wellSpacing: Double(self.wellSpacing), wellRadius: Double(self.wellRadius))
            } else {
                // background thread!
                self.detectedCircles = OpenCVWrapper.detectCircles(self.newImage)
            }
            
            if (self.detectedCircles != nil) {
                let circleArray = self.detectedCircles.circlesArray as NSMutableArray
                for (value) in circleArray {
                    let circle = value as! Circle
                    self.drawCircle(circle, color: UIColor.green.cgColor)
                }
            }
            
            DispatchQueue.main.async {
                self.hideProgressBar()
//                self.circleDetectedImage = self.newImage
                self.setupScrollView()
                self.showAddRemove()
                
                let prefs = UserDefaults.standard;
                if (!prefs.bool(forKey: "helpSeen")) {
                    prefs.set(true, forKey: "helpSeen");
                    self.displayHelpAlert()
                }
            }
        }
    }
    
    func showAddRemove() {
//        modeBackground.isHidden = false
    }
    
    
    
    func setEditMode() {
        switch (mode) {
        case .add:
//            modeLabel.text = "Add Circles"
//            modeBackground.backgroundColor = UIColor.green;
            break;
        case .delete:
//            modeLabel.text = "Delete Circles"
//            modeBackground.backgroundColor = UIColor.red;
            break;
        }
        
    }
    
    func hideProgressBar() {
        hud.dismiss(animated: true)
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    func displayHelpAlert() {
        let alert = UIAlertController(title: "Circle detection complete", message: "Please review the image and make any corrections by tapping on the image where a circle should've been detected", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showProgressBar(_ msg:String) {
        hud = JGProgressHUD(style: JGProgressHUDStyle.dark)
        hud.textLabel.text = msg
        hud.show(in: self.view)
        
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawnCircleDict = NSMutableDictionary()
        imageView = UIImageView(image: newImage)
        detectCircles()
        setEditMode()
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.setToolbarHidden(false, animated: false)
        //setupScrollView()
        self.displayHelpAlert()
        
        self.analysisDesc.text = self.desc
        self.testName.text = self.name
        
        
        segmentControl.selectedSegmentIndex = 0
        let barItem = UIBarButtonItem(customView: segmentControl)
        let barSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let barObjects: Array<UIBarButtonItem> = [barSpace, barItem, barSpace]
        self.toolbarItems = barObjects
        
        segmentControl.addTarget(self, action: #selector(switchMode), for: UIControlEvents.valueChanged)
        
//        self.navigationController?.toolbar.setValue(true, forKey: "hidesShadow")
        self.navigationController?.toolbar.barTintColor = UIColor.white
        
    }
    
    func switchMode(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1 {
            mode = .delete
        }
        else {
            mode = .add
        }
        setEditMode()
    }
    
    func setupScrollView() {
        
        let image = newImage
        imageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size:(image?.size)!)
        scrollView.addSubview(imageView)
        
        // 2
        scrollView.contentSize = (image?.size)!
        
        // 3
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action:#selector(DetectedCirclesViewController.scrollViewDoubleTapped(_:)));
//        doubleTapRecognizer.numbequired = 2
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapRecognizer)
//        let singleTap = UITapGestureRecognizer(target: self,"singleTap:",singleTap(_:));
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(DetectedCirclesViewController.singleTap(_:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.require(toFail: doubleTapRecognizer)
        scrollView.addGestureRecognizer(singleTap)
        
        // 4
        let scrollViewFrame = scrollView.frame
        let scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width
        let scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height
        let minScale = min(scaleWidth, scaleHeight);
        scrollView.minimumZoomScale = minScale;
        
        // 5
        scrollView.maximumZoomScale = 1.0
        scrollView.zoomScale = minScale;
        
        // 6
        centerScrollViewContents()
    }
    
    func centerScrollViewContents() {
        let boundsSize = scrollView.bounds.size
        var contentsFrame = imageView.frame
        
        if contentsFrame.size.width < boundsSize.width {
            contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0
        } else {
            contentsFrame.origin.x = 0.0
        }
        
        if contentsFrame.size.height < boundsSize.height {
            contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0
        } else {
            contentsFrame.origin.y = 0.0
        }
        
        imageView.frame = contentsFrame
    }
    
    func singleTap(_ recognizer: UITapGestureRecognizer) {
        let p2 = recognizer.location(in: imageView);
        
        if (mode == .add) {
            let c = Circle(cgFloat: p2.x, y: p2.y, radius: CGFloat(60));
            addCircle(c!)
        } else {
            removeCircle(p2.x, pY: p2.y)
        }
        
    }
    
    func addCircle(_ c : Circle) {
        let nc = OpenCVWrapper.fineTuneUserTap(c.x, y: c.y);
        detectedCircles.add(nc)
        drawCircle(nc!, color: UIColor.green.cgColor)
    }
    
    func removeCircle(_ pX : CGFloat, pY : CGFloat) {
        let key = detectedCircles.removeCircle(at: pX, y: pY)
        
        if let myKey = key {
            let layer = drawnCircleDict.object(forKey: myKey)
            (layer as AnyObject).removeFromSuperlayer();
        }
    }
    
    func scrollViewDoubleTapped(_ recognizer: UITapGestureRecognizer) {
        // 1
        let pointInView = recognizer.location(in: imageView)
        
        // 2
        var newZoomScale = scrollView.zoomScale * 1.5
        newZoomScale = min(newZoomScale, scrollView.maximumZoomScale)
        
        // 3
        let scrollViewSize = scrollView.bounds.size
        let w = scrollViewSize.width / newZoomScale
        let h = scrollViewSize.height / newZoomScale
        let x = pointInView.x - (w / 2.0)
        let y = pointInView.y - (h / 2.0)
        
        let rectToZoomTo = CGRect(x: x, y: y, width: w, height: h);
        
        // 4
        scrollView.zoom(to: rectToZoomTo, animated: true)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toAnalysis") {
            let results = OpenCVWrapper.processImage(withOpenCV: self.detectedCircles) as NSArray!
            print("[1] Returned from processing Image")
            let jsonData = toJSON(results!)
            print("[3] Got JSON Data")
            let timestamp = saveAnalysis(jsonData)
            let vc = segue.destination as! ResultsViewController;
            vc.resultsImage = newImage
            vc.resultsData = results
            vc.analysisName = name;
            vc.analysisTimestamp = timestamp
            
        }
    }
    
    func toJSON(_ results : NSArray) -> String {
        let data = NSMutableArray()
        for res in results {
            data.add((res as AnyObject).toJSONDictionary());
        }
        let nsData = NSArray(array: data);
        let jsonData = try! JSONSerialization.data(withJSONObject: nsData, options: [])
        print("[2] Complete serialization and returning")
        return String(data: jsonData, encoding: String.Encoding.utf8)!
    }
    
    
    func saveAnalysis(_ results : String) -> Int64 {
        let timestamp = Utils.getCurrentMillis()
        Utils.saveImages(newImage, name:String(timestamp))
        _ = AnalysisData.createInManagedObjectContext(managedObjectContext, name:name, desc:desc, date:timestamp, imgUrl:String(timestamp), results:results)
        do {
            try self.managedObjectContext.save()
        } catch {
            print(error)
        }
        
        return timestamp
    }
    
    func drawCircle(_ cir : Circle, color : CGColor) {
        let shapeLayer = CAShapeLayer();
        shapeLayer.position = CGPoint(x: cir.x - cir.radius , y: cir.y - cir.radius)
        
        let path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: cir.radius * 2, height: cir.radius * 2))
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = color
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 5
        
        
        drawnCircleDict.setObject(shapeLayer, forKey: cir.getKey() as NSCopying)
        imageView.layer.addSublayer(shapeLayer)
    }
    

    
    
    // UIScrollViewDelegate
    // -----------------------
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

