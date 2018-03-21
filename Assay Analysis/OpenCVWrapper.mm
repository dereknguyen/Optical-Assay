//
//  OpenCVWrapper.m
//  Optical Assay
//
//  Created by Derek Nguyen on 2/25/18.
//  Copyright © 2018 Optical Assay Team. All rights reserved.
//

#import <opencv2/opencv.hpp>

#import "OpenCVWrapper.h"
#import "OpenCVCircles.hpp"
#import "CircleSegment.hpp"
#import "Circle.h"
#import "UIImage+OpenCV.h"

@implementation OpenCVWrapper : NSObject

static CircleSegment cs;

+ (NSMutableArray *)processImageWithOpenCV:(CirclePosition *)circles {
    
    printf("(from OpenCVWrapper.mm)\n\tprocessImageWithOpenCV(): Have %d circles.\n", circles.numCircles);
    
    cv::Mat greyMat;
    NSMutableArray *results = [[NSMutableArray alloc] init];
    vector<Vec3f> vecCircles([circles numCircles]);
    NSMutableArray *circlesArray = [circles circlesArray];
    
    // Convert NSMutableArray circleArray to vector<Vec3f> vecCircles
    for (int i = 0; i < circlesArray.count; i++) {
        Circle *temp = circlesArray[i];
        
        // 3 float: x, y, radius
        Vec3f vec(temp.x, temp.y, temp.radius);
        vecCircles[i] = vec;
    }
    
    // Perform color analysis on detected circles
    vector<CircleSegment::ImageStats> analysisResults = cs.performAnalysis(vecCircles);

    // Convert ImageStats struture of each circle to NSMutableArray
    for (CircleSegment::ImageStats image: analysisResults) {
        
        AnalysisResult *current = [[AnalysisResult alloc] initWithFloat:image.circleInfo[0]
                                                                      y:image.circleInfo[1]
                                                                 radius:image.circleInfo[2]
                                                                 result:image.hsvMean[0]];
        [results addObject:current];
    }
    
    return results;
}

+ (CirclePosition *)detectCircles:(UIImage *)inputImage {
    CirclePosition *positions = [[CirclePosition alloc] init];
    cv::Mat matImage = [inputImage CVMat];
    cv::Mat bgrMat;
   
    
    // Convert image to BGR format
    cvtColor(matImage, bgrMat, CV_RGBA2BGR);
    
    // Detect circle with given image. Will use cv::HoughCircle.
    // Set Hough parameters base on phone position.
    vector<Vec3f> circles = cs.getCirclesPosition(bgrMat, "iPhoneX");
    
    // Convert circles in vector form to Circle object format
    for (Vec3f vec: circles) {
        Circle *temp = [[Circle alloc] initWithFloat:vec[0] y:vec[1] radius:vec[2]];
        [positions addCircle:temp];
    }
    
    return positions;
}

+ (CirclePosition *)detectCircles:(UIImage *)inputImage
                   wellplateWidth:(double)wellplateWidth
                  wellplateLength:(double)wellplateLength
                      wellSpacing:(double)wellSpacing
                       wellRadius:(double)wellRadius

{
    CirclePosition *positions = [[CirclePosition alloc] init];
    cv::Mat matImage = [inputImage CVMat];
    cv::Mat bgrMat;
    
    
    // Convert image to BGR format
    cvtColor(matImage, bgrMat, CV_RGBA2BGR);
    
    // Detect circle with given image. Will use cv::HoughCircle.
    // Set Hough parameters base on phone position.
//    vector<Vec3f> circles = cs.getCirclesPosition(bgrMat, "iPhoneX");
    vector<Vec3f> circles = cs.getCirclesPositionWithWellValues(bgrMat, "iPhoneX", wellplateWidth, wellplateLength, wellSpacing, wellRadius);
    
    // Convert circles in vector form to Circle object format
    for (Vec3f vec: circles) {
        Circle *temp = [[Circle alloc] initWithFloat:vec[0] y:vec[1] radius:vec[2]];
        printf("X: %f\n", vec[0]);
        printf("Y: %f\n", vec[1]);
        printf("R: %f\n\n", vec[2]);
        [positions addCircle:temp];
    }
    
    return positions;
}


+ (Circle *)fineTuneUserTap:(CGFloat)x y:(CGFloat)y {
    printf("(from OpenCVWrapper.mm) fineTuneUserTap\n");
    
    // Detect circle around user's tapped coordinate
    Vec3f vec = cs.findCircleFromCGFloats(x, y);
    
    // Convert to Circle object
    Circle *c = [[Circle alloc]initWithFloat:vec[0] y:vec[1] radius:vec[2]];
    return c;
}

@end
