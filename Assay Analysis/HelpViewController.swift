//
//  HelpViewController.swift
//  Assay Analysis
//
//  Created by Anthony Annuzzi on 1/20/16.
//  Copyright © 2016 CPE350 Capstone. All rights reserved.
//

class HelpViewController : UIViewController {
    
    @IBAction func tappedClose(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet var webView: UIWebView!
    
    func loadAddressURL(_ name : String){
        let url = Bundle.main.url(forResource: name, withExtension: "html");
        let request = URLRequest(url: url!)
        webView.loadRequest(request)
    }
    
    @IBAction func topOfPage(_ sender: AnyObject) {
        loadAddressURL("help");
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setToolbarHidden(true, animated: false)
        loadAddressURL("help");
    }
}
