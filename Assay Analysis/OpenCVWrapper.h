//
//  OpenCVWrapper.h
//  Optical Assay
//
//  Created by Derek Nguyen on 2/25/18.
//  Copyright © 2018 Optical Assay Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CirclePosition.h"
#import "AnalysisResult.h"

@interface OpenCVWrapper : NSObject

/*!
 Process source image with given detected circles coordinate and radius.
 
 @param circles The detected circles center coordinate and radius
 @return Result in NSMutableArray form.
 */
+ (NSMutableArray *)processImageWithOpenCV:(CirclePosition *)circles;

/*!
 Process image with cv::HoughCircle to obtain circle coordinate and position
 
 @param inputImage The image to be processed
 @return CirclePosition object that contain center x, y, and radius of the circle.
 */
+ (CirclePosition *)detectCircles:(UIImage *)inputImage;

/*!
 Process the area around where the use tap to detect any circle.
 
 @param x Horizontal position where user tapped.
 @param y Vertical position where user tapped.
 @return Circle object that contain the new location and radius of the detected circle.
 */
+ (Circle *)fineTuneUserTap:(CGFloat)x y:(CGFloat)y;



+ (CirclePosition *)detectCircles:(UIImage *)inputImage
                   wellplateWidth:(double)wellplateWidth
                  wellplateLength:(double)wellplateLength
                      wellSpacing:(double)wellSpacing
                       wellRadius:(double)wellRadius;

@end
