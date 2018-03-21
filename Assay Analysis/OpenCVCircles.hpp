//
//  OpenCVCircles.hpp
//  Optical Assay
//
//  Created by Derek Nguyen on 2/25/18.
//  Copyright © 2018 Optical Assay Team. All rights reserved.
//

#ifndef OpenCVCircles_hpp
#define OpenCVCircles_hpp

#include <opencv2/opencv.hpp>


class OpenCVCircles {
    
public:
    
    /*!
     Detect all circles in grayscale image by using OpenCV HoughCircle function.
     
     @param image the source image.
     @param dp Inverse ratio of the accumulator resolution to the image resolution.
     @param min_dist Minimum distance between the centers of the detected circles.
     @param param_1 The higher threshold of the two passed to the Canny() edge detector (the lower one is twice smaller).
     @param param_2 The accumulator threshold for the circle centers at the detection stage.
     @param min_radius Minimum radius of circle.
     @param max_radius Maximum radius of circle.
     @return All detected circles' position and radius in vector form.
     */
    static std::vector<cv::Vec3f> detectCirclesReturnVector(cv::Mat image,
                                                            double dp,
                                                            double min_dist,
                                                            double param_1,
                                                            double param_2,
                                                            int min_radius,
                                                            int max_radius);
    
    /*!
     Detect all circles in grayscale image by using OpenCV HoughCircle function.
     
     @param image the source image.
     @param dp Inverse ratio of the accumulator resolution to the image resolution.
     @param min_dist Minimum distance between the centers of the detected circles.
     @param param_1 The higher threshold of the two passed to the Canny() edge detector (the lower one is twice smaller).
     @param param_2 The accumulator threshold for the circle centers at the detection stage.
     @param min_radius Minimum radius of circle.
     @param max_radius Maximum radius of circle.
     @return All detected circles' position and radius in matrix form.
     */
    static cv::Mat detectCirclesReturnMat(cv::Mat image,
                                            double dp,
                                            double min_dist,
                                            double param_1,
                                            double param_2,
                                            int min_radius,
                                            int max_radius);
};


#endif /* OpenCVCircles_hpp */
