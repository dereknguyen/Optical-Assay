//
//  AnalysisResult.h
//  Optical Assay
//
//  Created by Derek Nguyen on 2/25/18.
//  Copyright © 2018 Optical Assay Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Circle.h"

@interface AnalysisResult : NSObject <JSON>

/*! Analyzed Circle */
@property Circle *circle;

/*! Concentration result of circle*/
@property float result;

/*!
 @brief Initialized the result location and value
 @param x The center x location of circle.
 @param y The center y location of circle.
 @param radius The radius of the circle.
 @param result The analyzed color result of the circle.
 */
- (id)initWithFloat:(float)x y:(float)y radius:(float)radius result:(float)result;

@end
