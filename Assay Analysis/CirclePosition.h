//
//  CirclePosition.h
//  Optical Assay
//
//  Created by Derek Nguyen on 2/25/18.
//  Copyright © 2018 Optical Assay Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Circle.h"

@interface CirclePosition : NSObject

/*! The array of circles we currently detected */
@property (strong, nonatomic) NSMutableArray *circlesArray;

/*!
 @brief Add new circle to the array of circles.
 @param circle The new circle to be added.
 */
- (void)addCircle:(Circle *)circle;

/*!
 @brief Remove circle at specified location.
 @param x The x location of the circle.
 @param y The y locaiton of the circle.
 @return the removed circle.
 */
- (NSString *)removeCircleAt:(CGFloat)x y:(CGFloat)y;

/*!
 @brief Get number of circles currently have.
 @return The number of circles.
 */
- (int)numCircles;

@end
