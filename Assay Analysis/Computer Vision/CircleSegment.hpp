//
//  CircleSegment.hpp
//  Optical Assay
//
//  Created by Derek Nguyen on 2/25/18.
//  Copyright © 2018 Optical Assay Team. All rights reserved.
//

#ifndef CircleSegment_hpp
#define CircleSegment_hpp

#include <opencv2/opencv.hpp>
#include <CoreGraphics/CoreGraphics.h>

#include <stdio.h>
#include <iostream>
#include <iomanip>
#include <fstream>
#include <vector>

#include "OpenCVCircles.hpp"

using namespace std;
using namespace cv;

class CircleSegment {
    
public:
    
    /*! Possible phone model*/
    enum PhoneModel {
        iPhoneX
    };
    
    /*! Parameter structure for OpenCV HoughTransform */
    typedef struct HoughParameters {
        double dp;          /*!< The inverse ratio of resolution */
        double min_dist;    /*!< Minimum distance between detected centers */
        double param_1;     /*!< Upper threshold for the internal Canny edge detector */
        double param_2;     /*!< Threshold for center detection */
        int min_radius;     /*!< Minimum radius to be detected. If unknown, put zero as default */
        int max_radius;     /*!< Maximum radius to be detected. If unknown, put zero as default */
    } HoughParameters;
    
    HoughParameters houghParams;
    
    /*! Detected Hough circles */
    vector<Vec3f> circles;
    
    /*! The main image */
    Mat image;
    
    /*! Processed statistics of each circle image */
    typedef struct ImageStats {
        Mat img;            /*!< The cut out circle */
        Vec3f circleInfo;   /*!< The cut out circle */
        Scalar bgrMean;     /*!< Mean BGR value of circle */
        Scalar bgrStdv;     /*!< Standard deviation BGR value of circle */
        Scalar hsvMean;     /*!< Mean HSV value of circle */
        Scalar hsvStdv;     /*!< Standard deviation HSV value of circle */
        Scalar luvMean;     /*!< Mean LUV value of circle */
        Scalar luvStdv;     /*!< Standard deviation LUV value of circle */
        Scalar ycrcbMean;   /*!< Mean YCrCb value of circle */
        Scalar ycrcbStdv;   /*!< Standard deviation YCrCb value of circle */
    } ImageStats;
    
    /*!
     Crop out detected circles from input image.
     
     @param image_src The srouce image to be cropped.
     @param crop_dest Location to store cropped image.
     */
    void cropTubes(Mat image_src, vector<Mat> *crops_dest);
    
    /*!
     Make segmentation mask for the cropped out tubes.
     
     @param tube_src The srouce images to make mask for.
     @param masks_dest Location to store made masks;
     */
    void makeMasks(vector<Mat> tubes_src, vector<Mat> *masks_dest);
    
    /*!
     Apply premade mask to the cropped out tube images.
     Perform bitwise & on all of the masks and crops.
     
     @param masks_src The premade masks.
     @param crops_src The cropped out tubes images.
     @param result_dest Location to store images with applied masks.
     */
    void applyMasks(vector<Mat> *masks_src, vector<Mat> *crops_src, vector<Mat> *result_dest);
    
    /*!
     Derive basic statistical data from images and filter out bad wells
     
     @param solutionPixels_src Tubes image with mask
     @param masks_src The segmentation masks
     @param result_dest Location to store derived image stats
     */
    void getStats(vector<Mat> solutionPixels_src, vector<Mat> masks_src, vector<CircleSegment::ImageStats> *results_dest);
    
    /*!
     Perform the rest of the analysis.
     
     @param circles new circles to perform analysis on, will overwrite existing one.
     @return Statistical value of each processed tubes.
     */
    vector<CircleSegment::ImageStats> performAnalysis(vector<Vec3f> circles);
    
    /*!
     Get circles' positions and radii from input wellplate image.
     
     @param image The well plate image.
     @param phoneModel Phone model of user to determine Hough parameters
     @return Detected positions of each circles along with their detected radii.
     */
    vector<Vec3f> getCirclesPosition(Mat image, string phoneModel);
    
    
    
    /*!
     Normalize the gradient of image.
     
     @param Input image.
     @return normalized image.
     */
//    Mat normalizeGradient(Mat img);
    
    /*! Returns a hough circle within the area specified */
    Vec3f findOneCircle(Vec3f approx);
    
    /*!
     Add a user's tap to the list of circles
     
     @param x X Position.
     @param y Y Position.
     @return Vector format of circle position
     */
    Vec3f findCircleFromCGFloats(CGFloat x, CGFloat y);
};


#endif /* CircleSegment_hpp */














