//
//  OpenCVCircles.cpp
//  Optical Assay
//
//  Created by Derek Nguyen on 2/25/18.
//  Copyright © 2018 Optical Assay Team. All rights reserved.
//

#include "OpenCVCircles.hpp"

using namespace cv;
using namespace std;

vector<Vec3f> OpenCVCircles::detectCirclesReturnVector(Mat image, double dp, double min_dist, double param_1, double param_2, int min_radius, int max_radius) {
    cout << "(from OpenCVCircles.cpp detectCirclesReturnVector)" << endl;
    
    Mat cImage;
    
    if(image.empty()) {
        cout << "can not open image " << endl;
        return image;
    }
    
    if (image.type() == CV_8UC1) {
        cout << "\tHough Circle: Input image is 8-bit 1 Channel: grayscale\n" << endl;
        cvtColor(image, cImage, CV_GRAY2RGB);
    } else {
        cout << "\tHough Circle: Input image is NOT 1 Channel: color\n" << endl;
        cImage = image;
        cvtColor(image, image, CV_RGB2GRAY);
    }

    vector<Vec3f> circles;
    
    /*
     HoughCircles
     
     image: 8-bit, single-channel, grayscale input image.
     
     circles: Output vector of found circles. Each vector is encoded as a 3-elementfloating-point vector
     
     method: Detection method, see cv::HoughModes. Currently, the only implemented method is HOUGH_GRADIENT
     
     dp: Inverse ratio of the accumulator resolution to the image resolution.
         For example, if dp=1 , the accumulator has the same resolution as the input image.
         If dp=2 , the accumulator hashalf as big width and height.
     
     min_dist: Minimum distance between the centers of the detected circles.
               If the parameter is too small, multiple neighbor circles may be falsely detected in addition to a true one.
     
               If it is too large, some circles may be missed.
     param_1: First method-specific parameter. In case of CV_HOUGH_GRADIENT,
              it is the higherthreshold of the two passed to the Canny edge detector (the lower one is twice smaller).
     
     param_2: Second method-specific parameter. In case of CV_HOUGH_GRADIENT ,
              it is theaccumulator threshold for the circle centers at the detection stage.
              The smaller it is, the morefalse circles may be detected.
              Circles, corresponding to the larger accumulator values, will be returned first.
     
     minRadius: Minimum circle radius.
     maxRadius: Maximum circle radius.
     */
    HoughCircles(image, circles, CV_HOUGH_GRADIENT, dp, min_dist, param_1, param_2, min_radius, max_radius);

    
    return circles;
}


Mat OpenCVCircles::detectCirclesReturnMat(Mat image, double dp, double min_dist, double param_1, double param_2, int min_radius, int max_radius) {
    cout << "(from OpenCVCircles.cpp detectCirclesReturnMat)" << endl;
    
    Mat cImage;
    
    if(image.empty()) {
        cout << "can not open image " << endl;
        return image;
    }
    
//    cout << "(fom OpenCVCircles.hpp) detectCirclesReturnMat: Image type: " << image.type() << endl;
    
    if (image.type() == CV_8UC1) {
        cout << "\tHough Circle: Input image is 8-bit 1 Channel: grayscale\n" << endl;
        cvtColor(image, cImage, CV_GRAY2RGB);
    } else {
        cout << "\tHough Circle: Input image is NOT 1 Channel: color\n" << endl;
        cvtColor(image, image, CV_RGB2GRAY);
    }
    
    vector<Vec3f> circles;
    
    /*
     HoughCircles
     
     image: 8-bit, single-channel, grayscale input image.
     
     circles: Output vector of found circles. Each vector is encoded as a 3-elementfloating-point vector
     
     method: Detection method, see cv::HoughModes. Currently, the only implemented method is HOUGH_GRADIENT
     
     dp: Inverse ratio of the accumulator resolution to the image resolution.
     For example, ifdp=1 , the accumulator has the same resolution as the input image.
     If dp=2 , the accumulator hashalf as big width and height.
     
     min_dist: Minimum distance between the centers of the detected circles.
     If the parameter is too small, multiple neighbor circles may be falsely detected in addition to a true one.
     
     If it is too large, some circles may be missed.
     param_1: First method-specific parameter. In case of CV_HOUGH_GRADIENT,
     it is the higherthreshold of the two passed to the Canny edge detector (the lower one is twice smaller).
     
     param_2: Second method-specific parameter. In case of CV_HOUGH_GRADIENT ,
     it is theaccumulator threshold for the circle centers at the detection stage.
     The smaller it is, the morefalse circles may be detected.
     Circles, corresponding to the larger accumulator values, will bereturned first.
     
     minRadius: Minimum circle radius.
     maxRadius: Maximum circle radius.
     */
    HoughCircles(image, circles, CV_HOUGH_GRADIENT, dp, min_dist, param_1, param_2, min_radius, max_radius);
    
    for (size_t i = 0; i < circles.size(); i++) {
        Vec3i temp = circles[i];
        circle(cImage, Point(temp[0], temp[1]), temp[2], Scalar(255, 0, 0), 3, CV_AA);
        circle(cImage, Point(temp[0], temp[1]), temp[2], Scalar(255, 255, 255), 3, CV_AA);
    }
    
    return cImage;
}











