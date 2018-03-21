//
//  Circle.h
//  Optical Assay
//
//  Created by Derek Nguyen on 2/25/18.
//  Copyright © 2018 Optical Assay Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "JSON.h"

@interface Circle : NSObject <JSON>

/*! @brief x position of the circle center.*/
@property CGFloat x;

/*! @brief y position of the circle center.*/
@property CGFloat y;

/*! @brief radius of the circle.*/
@property CGFloat radius;

/*!
 @brief intialize circle with input values as CGFloats
 @param x The x position of the circle.
 @param y The y position of the circle.
 @param radius The radius of the circle.
 */
- (id)initWithCGFloat:(CGFloat)x y:(CGFloat)y radius:(CGFloat)radius;

/*!
 @brief intialize circle with input values as floats
 @param x The x position of the circle.
 @param y The y position of the circle.
 @param radius The radius of the circle.
 */
- (id)initWithFloat:(float)x y:(float)y radius:(float)radius;

/*!
 @brief Get the position description of the circle.
 @return The circle position in format "%.0f%.0f"
 */
- (NSString *)getKey;

@end
