//
//  CirclePosition.mm
//  Optical Assay
//
//  Created by Derek Nguyen on 2/25/18.
//  Copyright © 2018 Optical Assay Team. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <Foundation/Foundation.h>
#import "CirclePosition.h"

@implementation CirclePosition : NSObject

// add the new circle to circles array
- (void)addCircle:(Circle *)circle {
    [[self circlesArray] addObject:circle];
}

// Removing circle with given coordinate.
- (NSString *)removeCircleAt:(CGFloat)x y:(CGFloat)y {
    CGFloat minDistance = CGFLOAT_MAX;
    Circle *circle = nil;
    
    // Iterate through the array of detected circles
    for (Circle *tempCircle in self.circlesArray) {
        
        // Compute hypotenuse distance between the selected circle (x, y) and
        //   current iteration of the circle (tempCircle x, y)
        CGFloat distance = hypot(x - [tempCircle x], y - [tempCircle y]);
        
        // If the calculated distance is less than the minDistance
        //     then the current tempCircle is nearer to the selected circle.
        // Our goal is to select the nears circle to the coordinate.
        if (distance < minDistance) {
            minDistance = distance;
            circle = tempCircle;
        }
    }
    
    // If the minimum distance is within the diameter of the found nearest circle,
    //      then it must be the circle from the parameter coordinate (x, y).
    if (minDistance < [circle radius] * 2) {
        [[self circlesArray] removeObject:circle];     // Remove from array.
        return [circle getKey];                 // Return the circle data.
    }
    else {
        // Else, that coordinate parameter does not belong to any circle
        printf("(from CirclePosition.mm)\n\tremoveCircleAt returned nil.\n\n");
        return nil;
    }
    
}

// Return circles array count
- (int)numCircles {
    return (int)[[self circlesArray] count];
}

// Initializing
- (id)init {
    if ( self = [super init] ) {
        self.circlesArray = [[NSMutableArray alloc] init];
        return self;
    }
    else {
        printf("(from CirclePosition.mm) init returned nil.");
        return nil;
    }
}


@end
