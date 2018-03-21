//
//  UIImage+OpenCV.h
//  Optical Assay
//
//  Created by Derek Nguyen on 2/25/18.
//  Copyright © 2018 Optical Assay Team. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImage (OpenCV)

// cv::Mat to UIImage
+ (UIImage *)imageWithCVMat:(const cv::Mat &)cvMat orientation:(UIImageOrientation)orientation;
- (id)initWithCVMat:(const cv::Mat &)cvMat orientation:(UIImageOrientation)orientation;

// UIImage to cv::Mat
- (cv::Mat)CVMat;
- (cv::Mat)CVMat3;  // No alpha channel
- (cv::Mat)CVGrayscaleMat;

@end
