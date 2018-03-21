//
//  CirclePositions.swift
//  Assay Analysis
//
//  Created by Anthony Annuzzi on 2/1/16.
//  Copyright © 2016 CPE350 Capstone. All rights reserved.
//


import Foundation

class CirclePosition : NSObject {
    
    var dict = [String : Circle]()
    
    //override init() {}
    
    
    func addCircle(c : Circle) {
        NSLog("Circle %f %f", c.pX, c.pY)
    }
    
}
