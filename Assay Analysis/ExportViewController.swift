//
//  ExportViewController.swift
//  Assay Analysis
//
//  Created by Anthony Annuzzi on 2/20/16.
//  Copyright © 2016 CPE350 Capstone. All rights reserved.
//

import Foundation
import MessageUI
import SwiftyDropbox
import JGProgressHUD

class ExportViewController : UITableViewController, MFMailComposeViewControllerDelegate {
    
    // Data for upload
    var csvData : String!
    var analysisName : String!
    var analysisTimestamp : Int64!
    
    var exportData : Data!
    var exportFilename : String!
    
    var mailComposer : MFMailComposeViewController!
    var hud : JGProgressHUD!
    
    
    // Variables for success or fail
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        exportData = csvData.data(using: String.Encoding.utf8);
        guard let fileName = analysisName else { return }
        guard let timeStamp = analysisTimestamp else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, y"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mma"
        let millis = timeStamp
        let date = Date(timeIntervalSince1970: TimeInterval(millis/1000))
        
        exportFilename = "\(fileName) \(dateFormatter.string(from: date)) \(timeFormatter.string(from: date)).csv"
        
        switch indexPath.row {
        case 0:
            NSLog("Tapped mail")
            sendEmail()
        case 1:
            NSLog("Tapped dropbox")
            uploadDropbox()
        default:
            NSLog("Error")
            tappedClose(self)
        }
    }
    
    @IBAction func tappedClose(_ sender: AnyObject) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    func sendEmail() {
        if (MFMailComposeViewController.canSendMail()) {
            mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            mailComposer.setSubject("Assay Analysis Data")
            mailComposer.setMessageBody("Results for \(analysisName) are attached.", isHTML: false)
            mailComposer.addAttachmentData(exportData!, mimeType: "text/csv", fileName: exportFilename!)
            
            self.present(mailComposer, animated: true, completion: nil)
        }
    }
    
    func uploadDropbox() {
        if let client = DropboxClientsManager.authorizedClient {
            hud = JGProgressHUD(style: JGProgressHUDStyle.dark)
            hud.textLabel.text = "Uploading file"
            hud.show(in: self.view)
            UIApplication.shared.beginIgnoringInteractionEvents()
            let t0 = Utils.getCurrentMillis();
            
            client.files.upload(path: "/\(exportFilename!)", input: exportData!).response { response, error in
                if let metadata = response {
                    print("*** Upload file ***");
                    print("Name: \(metadata.name)")
                    print("Rev: \(metadata.rev)")
                    
                    self.progressDelay(t0)
                    
                    self.hud.textLabel.text = "Success"
                    self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                    
                    self.onSuccess()
                } else {
                    print(error!)
                    
                    self.progressDelay(t0)
                    
                    self.hud.textLabel.text = "Error Uploading File"
                    self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                    self.onError(error!.description);
                    
                }
            }
        } else {
//            Dropbox.authorizeFromController(self)
            DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                            controller: self,
                                            openURL: {(url: URL) -> Void in
                                                UIApplication.shared.openURL(url)
            })
        }
    }
    
    func progressDelay(_ t0:Int64) {
        let t1 = Utils.getCurrentMillis()
        let delay = 2000 - (t1 - t0)
        
        print("Delay for \(delay)")
        if (delay > 0) {
            Thread.sleep(forTimeInterval: Double(delay) / 1000)
        }
    }
    
    func onSuccess() {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            Thread.sleep(forTimeInterval: 2)
            DispatchQueue.main.async {
                UIApplication.shared.endIgnoringInteractionEvents()
                self.tappedClose(self)
            }
        }
    }
    
    func onError(_ error : String) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            Thread.sleep(forTimeInterval: 2)
            DispatchQueue.main.async {
                UIApplication.shared.endIgnoringInteractionEvents()
                self.hud.dismiss(animated: true)
                
                if (error.contains("HTTP Error401")) {
                    DropboxClientsManager.unlinkClients();
//                    Dropbox.authorizeFromController(self);
                    DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                    controller: self,
                                                    openURL: {(url: URL) -> Void in
                                                        UIApplication.shared.openURL(url)
                    })
                }
            }
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result.rawValue {
//        case MFMailComposeResultSent:
        case 2:
            hud = JGProgressHUD(style: JGProgressHUDStyle.dark)
            hud.textLabel.text = "Email Sent"
            hud.indicatorView = JGProgressHUDSuccessIndicatorView()
            hud.show(in: self.view)
            UIApplication.shared.beginIgnoringInteractionEvents()
            onSuccess()
//        case MFMailComposeResultSaved:
        case 1:
            hud = JGProgressHUD(style: JGProgressHUDStyle.dark)
            hud.textLabel.text = "Draft Saved"
            hud.indicatorView = JGProgressHUDSuccessIndicatorView()
            hud.show(in: self.view)
            UIApplication.shared.beginIgnoringInteractionEvents()
            onSuccess()
//        case MFMailComposeResultFailed:
        case 3:
            hud = JGProgressHUD(style: JGProgressHUDStyle.dark)
            hud.textLabel.text = "Error sending email"
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 2);
        default:
            break
        }
        
//        if result == MFMailComposeResultSent {
//            hud = JGProgressHUD(style: JGProgressHUDStyle.Dark)
//            hud.textLabel.text = "Email Sent"
//            hud.indicatorView = JGProgressHUDSuccessIndicatorView()
//            hud.showInView(self.view)
//            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
//            onSuccess()
//        } else if result == MFMailComposeResultSaved {
//            hud = JGProgressHUD(style: JGProgressHUDStyle.Dark)
//            hud.textLabel.text = "Draft Saved"
//            hud.indicatorView = JGProgressHUDSuccessIndicatorView()
//            hud.showInView(self.view)
//            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
//            onSuccess()
//        } else if result == MFMailComposeResultFailed {
//            hud = JGProgressHUD(style: JGProgressHUDStyle.Dark)
//            hud.textLabel.text = "Error sending email"
//            hud.indicatorView = JGProgressHUDErrorIndicatorView()
//            hud.showInView(self.view)
//            hud.dismissAfterDelay(2);
//        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setToolbarHidden(true, animated: false)
    }
}
