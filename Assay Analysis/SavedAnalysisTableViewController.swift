//
//  SavedAnalysisTableViewController.swift
//  Assay Analysis
//
//  Created by Anthony Annuzzi on 1/22/16.
//  Copyright © 2016 CPE350 Capstone. All rights reserved.
//
import CoreData
import Foundation

class SavedAnalysisTableViewController : UITableViewController, UISearchBarDelegate, UIGestureRecognizerDelegate {
    
    var rightBarButton = UIBarButtonItem()
    var leftBarButton = UIBarButtonItem()
    
    var data : [AnalysisData] = []
    var filteredData = [AnalysisData]()
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var navBarLine: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let rightItem = navigationItem.rightBarButtonItem {
            rightBarButton = rightItem
        }
        if let leftItem = navigationItem.leftBarButtonItem {
            leftBarButton = leftItem
        }
        
        navigationController?.setToolbarHidden(true, animated: true)
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
//        tableView.separatorColor = #colorLiteral(red: 0.1934049129, green: 0.3530084193, blue: 0.6147560477, alpha: 1)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barTintColor = UIColor.white
        
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        

        // MARK: Implementing Search function for entries
        navigationItem.searchController = searchController
    
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search recents analysis"
        definesPresentationContext = true
        
        let cellLongPress = UILongPressGestureRecognizer(target: self, action: #selector(handleCellLongPress))
        cellLongPress.delegate = self
        tableView.addGestureRecognizer(cellLongPress)
        
        //data = AnalysisData.loadSampleData()
    }
    
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentFor(_ searchText: String, scope: String = "All") {
        filteredData = data.filter({ (analysisData : AnalysisData) -> Bool in
            guard let analysisName = analysisData.name else { return false }
            return analysisName.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func cancelButton() -> UIBarButtonItem {
        return UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.done, target: self, action: #selector(cancelEditing))
    }
    
    func cancelEditing() {
        navigationController?.setToolbarHidden(true, animated: true)
        tableView.setEditing(false, animated: true)
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.leftBarButtonItem = leftBarButton
    }
    
    func handleCellLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            
            navigationItem.leftBarButtonItem = cancelButton()
            navigationItem.rightBarButtonItem = nil
            
            let touchPoint = sender.location(in: self.view)
            if let indexPath = self.tableView.indexPathForRow(at: touchPoint) {
                self.tableView.setEditing(true, animated: true)
                self.navigationController?.setToolbarHidden(false, animated: true)
                print(indexPath)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let allData = NSFetchRequest<NSFetchRequestResult>(entityName: "AnalysisData");
        allData.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do {
            data = try self.managedObjectContext.fetch(allData) as! [AnalysisData]
            tableView.reloadData()
        } catch {
            NSLog("Fetch error")
            let fetchError = error as NSError
            print(fetchError);
        }

    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredData.count
        }
        
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SavedAnalysisViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SavedAnalysisTableViewCell
        
        var analysisData: AnalysisData
        
        if isFiltering() {
            analysisData = filteredData[indexPath.row]
        }
        else {
            analysisData = data[indexPath.row]
        }
        
        let dateFormatter = DateFormatter()
//        formatter.dateFormat = "MMMM d, y h:mm a"
        dateFormatter.dateFormat = "MMMM d, y"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        let millis = analysisData.date!.int64Value
        let date = Date(timeIntervalSince1970: TimeInterval(millis/1000))

        

        
        if (analysisData.imgUrl != nil) {
            let path = analysisData.imgUrl!
            let imgUrl = Utils.getDocumentsDirectory().appendingPathComponent(path + "_thumb.png");
            cell.photoImageView.image = UIImage(contentsOfFile: imgUrl)
        } else {
            cell.photoImageView.image = nil
        }
        
        
        cell.nameLabel.text = analysisData.name
        cell.descLabel.text = timeFormatter.string(from: date)
//        cell.descLabel.text = analysisData.desc
        cell.dateLabel.text = dateFormatter.string(for: date)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let removedData = data[indexPath.row]
            
            
            if (removedData.imgUrl != nil) {
                Utils.deleteImages(removedData.imgUrl!)
            }
            
            
            managedObjectContext.delete(removedData)
            data.remove(at: indexPath.row)
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
            }

            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !self.tableView.isEditing {
            self.performSegue(withIdentifier: "showResults", sender: indexPath)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showResults") {
            let ndx = sender as! IndexPath
            let vc = segue.destination as! ResultsViewController;
//            let analysisData = data[ndx.row]
            let analysisData: AnalysisData
            
            if isFiltering() {
                analysisData = filteredData[ndx.row]
            }
            else {
                analysisData = data[ndx.row]
            }
            
            vc.analysisName = analysisData.name!;
            vc.analysisTimestamp = analysisData.date?.int64Value;
            if (analysisData.analysis != nil) {
                let data = fromJSON(analysisData.analysis!)
                vc.resultsData = data;
            }
            
            if (analysisData.imgUrl != nil) {
                let imgUrl = Utils.getDocumentsDirectory().appendingPathComponent(analysisData.imgUrl! + ".png")
                vc.resultsImage = UIImage(contentsOfFile: imgUrl)
            }
        }
    }
    
    func fromJSON(_ json : String) -> NSMutableArray {
        let data = json.data(using: String.Encoding.utf8)!;
        let jsonArray = try! JSONSerialization.jsonObject(with: data, options: []) as! NSArray;
        
        let result = NSMutableArray()
        for (jsonObj) in jsonArray {
            let analysisResult = AnalysisResult(jsonDictionary: jsonObj as! [NSString : AnyObject])
            result.add(analysisResult as Any);
        }
        return result;
    }
}

extension SavedAnalysisTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentFor(searchController.searchBar.text!)
    }
}

