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

/*!
 Convert cv::Mat to UIImage
 
 @param cvMat The cv::Mat object. Should be an image.
 @param orientation The current orientation of the image.
 @return UIImage format image.
 */
+ (UIImage *)imageWithCVMat:(const cv::Mat &)cvMat orientation:(UIImageOrientation)orientation;

/*!
 @param cvMat cv::Mat format data
 @param orientation The current orientation of the image.
 */
- (id)initWithCVMat:(const cv::Mat &)cvMat orientation:(UIImageOrientation)orientation;


- (cv::Mat)CVMat;   /*!< Full cv::Mat */
- (cv::Mat)CVMat3;  /*!< No alpha channel */
- (cv::Mat)CVGrayscaleMat; /*!< Single channel cv::Mat */

@end
