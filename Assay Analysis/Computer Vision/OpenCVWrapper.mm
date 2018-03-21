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
    
    NSLog(@"(from OpenCVWrapper.mm) Have %d circles.\n", circles.numCircles);
    
    cv::Mat greyMat;
    NSMutableArray *results = [[NSMutableArray alloc] init];
    
    vector<Vec3f> vecCircles([circles numCircles]);
    
    NSMutableArray *circlesArray = circles.circles;
    
    for (int i = 0; i < circlesArray.count; i++) {
        Circle *temp = circlesArray[i];
        Vec3f vec(temp.x, temp.y, temp.radius);
        vecCircles[i] = vec;
    }
    
    vector<CircleSegment::ImageStats> analysisResults = cs.performAnalysis(vecCircles);
    
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
    cv::Mat matImage = [inputImage CVMat];
    cv::Mat bgrMat;
    
    // Convert image to BGR format
    cvtColor(matImage, bgrMat, CV_RGBA2BGR);
    
    vector<Vec3f> circles = cs.getCirclesPosition(bgrMat, "iPhoneX");
    
    CirclePosition *positions = [[CirclePosition alloc] init];
    
    for (Vec3f vec: circles) {
        Circle *temp = [[Circle alloc] initWithFloat:vec[0] y:vec[1] radius:vec[2]];
        [positions addCircle:temp];
    }
    
    return positions;
}

+ (Circle *) fineTuneUserTap : (CGFloat)x y:(CGFloat)y {
    Vec3f vec = cs.findCircleFromCGFloats(x, y);
    Circle *c = [[Circle alloc]initWithFloat:vec[0] y:vec[1] radius:vec[3]];
    return c;
}

@end
