//
//  ResultsViewController.swift
//  Assay Analysis
//
//  Created by Anthony Annuzzi on 1/24/16.
//  Copyright © 2016 CPE350 Capstone. All rights reserved.
//

import SwiftyDropbox

class ResultsViewController : UIViewController, UIScrollViewDelegate {
    

    @IBOutlet weak var scrollView: UIScrollView!
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    var imageView : UIImageView!
    
    var analysisName : String!
    var resultsData : NSArray!;
    var analysisTimestamp  : Int64!
    var resultsImage : UIImage! = nil
    var lastZoomScale : CGFloat = -1
    
    // variables for please wait spinner
    var messageFrame = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    
    
    
    
    @IBAction func tappedDone(_ sender: AnyObject) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func hideProgressBar() {
        self.messageFrame.removeFromSuperview()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    func drawResults() {
        if (resultsData != nil) {
            resultsImage = drawText(resultsImage, results: resultsData)
        }
        setupScrollView()
    }
    
    func drawText(_ image : UIImage, results : NSArray) -> UIImage {
        let textColor = UIColor.red
        let textFont = UIFont(name: "Helvetica Bold", size: 32)!
        
        UIGraphicsBeginImageContext(image.size)
        
        let textFontAttributes = [NSFontAttributeName: textFont, NSForegroundColorAttributeName: textColor]
        
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        
        for data in results {
            let res = data as! AnalysisResult
            let cir = res.circle;
            let val = NSString(format: "%.1f", res.result)
            let rect = CGRect(x: (cir?.x)! - (cir?.radius)!/2, y: (cir?.y)! - (cir?.radius)!/4, width: image.size.width, height: image.size.height)
            val.draw(in: rect, withAttributes: textFontAttributes)
        }
        
        let newImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImg!
    }
    
    func showProgressBar(_ msg:String, _ indicator:Bool ) {
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 240, height: 50))
        strLabel.text = msg
        strLabel.textColor = UIColor.white
        messageFrame = UIView(frame: CGRect(x: view.frame.midX - 110, y: view.frame.midY - 25 , width: 220, height: 50))
        messageFrame.layer.cornerRadius = 15
        messageFrame.backgroundColor = UIColor(white: 0, alpha: 0.7)
        if indicator {
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            activityIndicator.startAnimating()
            messageFrame.addSubview(activityIndicator)
        }
        messageFrame.addSubview(strLabel)
        view.addSubview(messageFrame)
        
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.setToolbarHidden(true, animated: false)
        
        
        
        
        drawResults()
    }
    
    func setupScrollView() {
        let image = resultsImage
        imageView = UIImageView(image: resultsImage)
        imageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size:(image?.size)!)
        scrollView.addSubview(imageView)
        
        // 2
        scrollView.contentSize = (image?.size)!
        
        // 3
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ResultsViewController.scrollViewDoubleTapped(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        scrollView.addGestureRecognizer(doubleTapRecognizer)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(ResultsViewController.singleTap(_:)))
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
        NSLog("Image view (%f, %f)", p2.x, p2.y)
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
    
    
    func prepareGrid() -> String {
        if (resultsData == nil) {
            return ""
        }
        
        let analysisResults = resultsData as! [AnalysisResult];
        let sortedX = analysisResults.sorted(by: {$0.circle!.x < $1.circle!.x});
        let sortedY = analysisResults.sorted(by: {$0.circle!.y < $1.circle!.y});
        
       // var sortedYGrid = sortedXGrid.copy()
        
        print("sort by x:");
        print(sortedX);
        print("sort by y:");
        print(sortedY);
        
        var xValues = [CGFloat]();
        var i = 0;
        
        var avg : CGFloat = -1.0
        if (sortedX.count > 0) {
            while (i < sortedX.count - 1) {
                if (sortedX[i+1].circle!.x - sortedX[i].circle!.x < 30) {
                    if (avg < 0) {
                        avg = sortedX[i].circle!.x
                    } else {
                        avg += sortedX[i].circle!.x
                        avg /= 2
                    }
                } else {
                    if (avg < 0) {
                        avg = sortedX[i].circle!.x;
                    }
                    NSLog("Added obj: %f", avg)
                    xValues.append(avg)
                    avg = -1;
                }
                i += 1;
            }
        
            if (avg < 0) {
                xValues.append(sortedX[sortedX.count - 1].circle!.x)
            } else {
                avg += sortedX[sortedX.count - 1].circle!.x
                avg /= 2
                xValues.append(avg)
            }
        }
        
        print("xvalues");
        print(xValues)
        
        var yValues = [CGFloat]();
        i = 0;
        avg = -1;
        
        if (sortedY.count > 0) {
            while (i < sortedY.count - 1) {
                if (sortedY[i+1].circle!.y - sortedY[i].circle!.y < 30) {
                    if (avg < 0) {
                        avg = sortedY[i].circle!.y
                    } else {
                        avg += sortedY[i].circle!.y
                        avg /= 2
                    }
                } else {
                    if (avg < 0) {
                        avg = sortedY[i].circle!.y;
                    }
                    yValues.append(avg)
                    avg = -1
                }
                i += 1
            }
        
        
            if (avg < 0) {
                yValues.append(sortedY[sortedY.count - 1].circle!.y)
            } else {
                avg += sortedY[sortedY.count - 1].circle!.y
                avg /= 2
                yValues.append(avg)
            }
        }
        
        print("yvalues")
        print(yValues)
        
        var grid = [[CGFloat]](repeating: [CGFloat](repeating: 0, count: xValues.count), count: yValues.count)
        
        print(grid)
        
        for res in analysisResults {
            var xNdx : Int = 0;
            var yNdx : Int = 0;
            
//            for (i = 0; i < xValues.count; i += 1) {
            for i in 0..<xValues.count {
                let xAvg = xValues[i]
                if (abs(res.circle!.x - xAvg) < 40) {
                    xNdx = i;
                    break;
                }
            }
            
//            for (i = 0; i < yValues.count; i += 1) {
            for i in 0..<yValues.count {
                let yAvg = yValues[i]
                if (abs(res.circle!.y - yAvg) < 40) {
                    yNdx = i
                    break
                }
            }
            
            NSLog("Putting %.1f at %d, %d\n", res.result, xNdx, yNdx);
            grid[yNdx][xNdx] = CGFloat(res.result);
        }
        
        print(grid)
        
        let csv = NSMutableString()
//        for (i = 0; i < yValues.count; i += 1) {
        for i in 0..<yValues.count {
            let xRow = grid[i] as NSArray
            csv.append((xRow.componentsJoined(by: ",")))
            csv.append("\n");
        }
        
        return csv.appending("");
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toExport") {
            let vc = segue.destination as! ExportViewController;
            
            vc.csvData = prepareGrid()
            vc.analysisTimestamp = analysisTimestamp
            vc.analysisName = analysisName

        }
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
