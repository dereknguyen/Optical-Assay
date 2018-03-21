//
//  AnalysisData.swift
//  Assay Analysis
//
//  Created by Anthony Annuzzi on 1/25/16.
//  Copyright © 2016 CPE350 Capstone. All rights reserved.
//

import Foundation
import CoreData

class AnalysisData : NSManagedObject {

    @NSManaged var name: String?
    @NSManaged var date: NSNumber?
    @NSManaged var analysis: String?
    @NSManaged var desc: String?
    @NSManaged var imgUrl: String?
    
    class func createInManagedObjectContext(_ moc : NSManagedObjectContext,
                                            name : String,
                                            desc : String,
                                            date : Int64,
                                            imgUrl : String,
                                            results : String) -> AnalysisData {
        
        let newItem = NSEntityDescription.insertNewObject(forEntityName: "AnalysisData", into: moc) as! AnalysisData
        
        newItem.name = name
        newItem.desc = desc
        newItem.date = NSNumber(value: date as Int64)
        newItem.imgUrl = imgUrl
        newItem.analysis = results
        
        return newItem
    }

}
