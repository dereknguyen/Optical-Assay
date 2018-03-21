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

+ (NSMutableArray*) processImageWithOpenCV: (CirclePosition*) circles;
+ (CirclePosition*) detectCircles : (UIImage *)inputImage;
+ (Circle *) fineTuneUserTap : (CGFloat)x y:(CGFloat)y;

@end
