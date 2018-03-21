//
//  CircleSegment.cpp
//  Optical Assay
//
//  Created by Derek Nguyen on 2/25/18.
//  Copyright © 2018 Optical Assay Team. All rights reserved.
//

#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/opencv.hpp>
#include "CircleSegment.hpp"



void CircleSegment::cropTubes(Mat image_src, vector<Mat> *crops_dest) {
    
    /* [TWEAKABLE] Extra space around each crop. Negative to remove outer sides of crop box. */
    const int buffer = 4;
    
    cv::Rect cropRegion;
    vector<Vec3f>::iterator circleIterator;
    
    float x, y, radius;
    
    for (circleIterator = this->circles.begin(); circleIterator != this->circles.end(); ) {
        
        x = (*circleIterator)[0];
        y = (*circleIterator)[1];
        radius = (*circleIterator)[2];
        
        // Check to make sure position X and Y not less than 0
        //    width and height of circle does not exceed width and height of picture.
        // If it is, then the circle must be clipped out of bound
        if (x - (buffer + radius) <= 0 ||
            y - (buffer + radius) <= 0 ||
            x - (buffer + radius) + 2 * (buffer + radius) >= image_src.cols ||
            y - (buffer + radius) + 2 * (buffer + radius) >= image_src.rows) {
            
            circleIterator = this->circles.erase(circleIterator);
            cerr << "(from CircleSegment.hpp) cropTubes() erased a circle that was out of bounds" << endl;
            continue;
        }
        
        cropRegion = cv::Rect(x - (buffer + radius), y - (buffer + radius), 2 * (buffer + radius), 2 * (buffer + radius));
        
        // Store cropped image
        // Increase the size (automatic reallocation) of the allocated storage through push_back()
        (*crops_dest).push_back(image_src(cropRegion).clone());

        circleIterator++;
    }

}

// Create segmentation masks from tubes
void CircleSegment::makeMasks(vector<Mat> tubes_src, vector<Mat> *masks_dest) {
    Mat result, kernel, show;
    vector<Mat> bw_tubes(tubes_src.size());
    
    // Convert RGB to grayscale images
    for (int i  = 0; i < tubes_src.size(); i++) {
    
        /*
         Convert color take 4 param:
         - Source image
         - Destination image
         - Color to convert to
         - Destination's number of channel, default value is 0 if not specified.
                Will infer from soource image.
         */
        cvtColor(tubes_src[i], bw_tubes[i], CV_RGB2GRAY);
    }
    
    // Kernel for eroding
    kernel = getStructuringElement(MORPH_ELLIPSE, cv::Size(5, 5), cv::Point(0, 0));
    
    // For every tube:
    // [1] Perform thresholding with Otsu method
    // [2] Bitwis_not to inverse the threshhold image and obtain the mask
    // [3] erode result with kernel to remove artifacts.
    for (int i = 0; i < tubes_src.size(); i++) {

        threshold(bw_tubes[i], result, 0, 255, CV_THRESH_BINARY | CV_THRESH_OTSU);
        bitwise_not(result, result);
        erode(result, result, kernel);
        
        // Store the created mask
        (*masks_dest).push_back(result.clone());
    }
}

// Perform a bitwise_and on all of the masks and crops
void CircleSegment::applyMasks(vector<Mat> *masks_src, vector<Mat> *crops_src, vector<Mat> *result_dest) {
    Mat result, temp;
    
    for (int i = 0; i < (*masks_src).size(); i++) {
        
        // Convert back to BGR so that the value won't mess up the original cropped color image.
        cvtColor((*masks_src)[i], temp, CV_GRAY2BGR);
        
        // bitwise_and to apply mask
        bitwise_and((*crops_src)[i], temp, result);
        
        (*result_dest).push_back(result.clone());
    }
}

// Derive some basic statistical data from images & filter out bad wells
void CircleSegment::getStats(vector<Mat> solutionPixels_src, vector<Mat> masks_src, vector<CircleSegment::ImageStats> *results_dest) {
    Mat convertedImage;
    
    for (int i = 0; i < solutionPixels_src.size(); i++) {
        cout << "\t\tNumber " << i << endl;
        (*results_dest).push_back(ImageStats());
        
        // bgr stats
        meanStdDev(solutionPixels_src[i], (*results_dest)[i].bgrMean, (*results_dest)[i].bgrStdv, masks_src[i]);
        cout << "\t\tbgr mean: " << (*results_dest)[i].bgrMean << endl;
        
        // hsv stats
        cvtColor(solutionPixels_src[i], convertedImage, CV_BGR2HSV);
        meanStdDev(convertedImage, (*results_dest)[i].hsvMean, (*results_dest)[i].hsvStdv, masks_src[i]);
        cout << "\t\thsv mean: " << (*results_dest)[i].hsvMean << endl;
        
        // CIE_Luv
        cvtColor(solutionPixels_src[i], convertedImage, CV_BGR2Luv);
        meanStdDev(convertedImage, (*results_dest)[i].luvMean, (*results_dest)[i].luvStdv, masks_src[i]);
        cout << "\t\tluv mean: " << (*results_dest)[i].luvMean << endl;
        
        // YCrCb
        cvtColor(solutionPixels_src[i], convertedImage, CV_BGR2YCrCb);
        meanStdDev(convertedImage, (*results_dest)[i].ycrcbMean, (*results_dest)[i].ycrcbStdv, masks_src[i]);
        cout << "\t\tycrcb mean: " << (*results_dest)[i].ycrcbMean << endl;
        
        // Put tube thresholding conditions here
        (*results_dest)[i].img = solutionPixels_src[i];
        (*results_dest)[i].circleInfo = this->circles[i];
        cout << "\t\tcircle mean: " << (*results_dest)[i].circleInfo << endl << endl;
        
    }
}

vector<CircleSegment::ImageStats> CircleSegment::performAnalysis(vector<Vec3f> circles) {
    this->circles = circles;
    cout << "\n(from CircleSegment.cpp) performAnalysis()"<< endl;
    cout << "\t1: Got circles " << this->circles.size() << endl;
    
    // Allocating memory
    vector<Mat> crops; crops.reserve(this->circles.size());
    vector<Mat> masks; masks.reserve(this->circles.size());
    vector<Mat> maskedCrops; maskedCrops.reserve(this->circles.size());
    vector<CircleSegment::ImageStats> imageStats; imageStats.reserve(this->circles.size());
    
    // [1] Crop
    cropTubes(this->image, &crops);
    cout << "\t2: Made crops " << crops.size() << endl;
    
    // [2] Use thresholding to create mask
    makeMasks(crops, &masks);
    cout << "\t3: Made masks " << masks.size() << endl;
    
    // [3] Apply the mask to cropped images
    applyMasks(&masks, &crops, &maskedCrops);
    cout << "\t4: Applied masks " << maskedCrops.size() << endl;
    
    // [4] Get color data
    
    cout << "\t5: Analyzing " << crops.size() << " circles:\n" << endl;
    getStats(maskedCrops, masks, &imageStats);
    cout << "\t\tAnalyzed " << imageStats.size() << " circles\n" << endl;
    
    
    return imageStats;
}

// Set Hough Circle parameter base on device
void chooseParams(CircleSegment::PhoneModel phone, CircleSegment::HoughParameters *hp) {

    switch (phone) {
        case CircleSegment::iPhoneX:
            hp->dp = 1;
            hp->min_dist = 50;
            hp->param_1 = 99;
            hp->param_2 = 31;
            hp->min_radius = 70;
            hp->max_radius = 140;
            break;
        case CircleSegment::autoCalculate:
            
            break;
        default:
            cerr << "(from CircleSegment.cpp)\n\tDid not select iPhone model, iPhone5s default\n" << endl;
            hp->dp = 1;
            hp->min_dist = 100;
            hp->param_1 = 100;
            hp->param_2 = 31;
            hp->min_radius = 40;
            hp->max_radius = 70;
            break;
    }
}



vector<Vec3f> CircleSegment::getCirclesPosition(Mat image, string phoneModel) {
    
    Mat channels[3];
    Mat convertedImage;
    
    this->image = image;
    
    // Convert image to HSV
    cvtColor(this->image, convertedImage, CV_BGR2HSV);
    
    // Take images cvtImg and store the H S and V into channels[1] [2] and [3]... each is a matrix
    split(convertedImage, channels);
    
    // TODO: Select iPhone model
//    chooseParams(CircleSegment::iPhoneX, &(this->houghParams));
    
    Mat saturation = channels[1];
    
    // Perform HoughCirclesTransform
    this->circles = OpenCVCircles::detectCirclesReturnVector(saturation,
                                                             this->houghParams.dp,
                                                             this->houghParams.min_dist,
                                                             this->houghParams.param_1,
                                                             this->houghParams.param_2,
                                                             this->houghParams.min_radius,
                                                             this->houghParams.max_radius);
    
    return this->circles;
}

void calculateParams(double wellSpacing, double wellRadius, CircleSegment::HoughParameters *hp) {
    hp->dp = 1;
    hp->min_dist = wellSpacing - 20.0;
    hp->param_1 = 100;
    hp->param_2 = 31;
    hp->min_radius = (int)wellRadius - 20;
    hp->max_radius = (int)wellRadius + 20;
}


vector<Vec3f> CircleSegment::getCirclesPositionWithWellValues(Mat image,
                                                              string phoneModel,
                                                              double wellplateWidth,
                                                              double wellplateLength,
                                                              double wellSpacing,
                                                              double wellRadius) {

    Mat channels[3], result, convertedImage, grayscale;
    this->image = image;

    // Convert image to HSV
    cvtColor(this->image, convertedImage, CV_BGR2HSV);
    
    // Take images cvtImg and store the H S and V into channels[1] [2] and [3]... each is a matrix
    split(convertedImage, channels);
    
    Mat saturation = channels[1];
    
    cvtColor(image, grayscale, CV_RGB2GRAY);
    
    // Using Otsu to get the threshold value. Use this as the high threshold of Canny in HoughCircles
    double param1 = threshold(saturation, result, 0, 255, CV_THRESH_OTSU | CV_THRESH_BINARY) * 0.55;
    
    // Original setting, keeping for reference
    //    this->houghParams.dp = 1;
    //    this->houghParams.min_dist = 100;
    //    this->houghParams.param_1 = 70;
    //    this->houghParams.param_2 = 31;
    //    this->houghParams.min_radius = 40;
    //    this->houghParams.max_radius = 70;
    
    this->houghParams.dp = 1;
    this->houghParams.min_dist = wellSpacing - 20;
    this->houghParams.param_1 = param1;
    this->houghParams.param_2 = 33;
    this->houghParams.min_radius = (int)wellRadius * 0.5;
    this->houghParams.max_radius = (int)wellRadius;
    
    cout << "\nCurrent HoughCircles() parameters" << endl;
    cout << "\tdp: " << houghParams.dp << endl;
    cout << "\tmin_dist: " << houghParams.min_dist << endl;
    cout << "\tparam_1: " << houghParams.param_1 << endl;
    cout << "\tparam_2: " << houghParams.param_2 << endl;
    cout << "\tmin_radius: " << houghParams.min_radius << endl;
    cout << "\tmax_radius: " << houghParams.max_radius << endl;
    
    // Perform HoughCirclesTransform
    this->circles = OpenCVCircles::detectCirclesReturnVector(saturation,
                                                             this->houghParams.dp,
                                                             this->houghParams.min_dist,
                                                             this->houghParams.param_1,
                                                             this->houghParams.param_2,
                                                             this->houghParams.min_radius,
                                                             this->houghParams.max_radius);
    
    return this->circles;
}


// Returns a hough circle within the area specified
Vec3f CircleSegment::findOneCircle(Vec3f approx) {
    
    Mat channels[3], cvtTube, cropTube;
    cv::Rect cropRegion;
    vector<Vec3f> foundCircles;
    Vec3f newCircle;
    
    float crop_x, crop_y;
    float x = approx[0];
    float y = approx[1];
    float radius = approx[2];
    
    const int buffer = 30;
    
    // Check to make sure position X and Y not less than 0
    //    width and height of circle does not exceed width and height of picture.
    // If it is, then the circle must be clipped out of bound
    if (x - (radius + buffer) > 0 &&
        y - (radius + buffer) > 0 &&
        x - (radius + buffer) + 2 * (radius + buffer) < (this->image).cols &&
        y - (radius + buffer) + 2 * (radius + buffer) < (this->image).rows) {
        
        crop_x = x - (radius + buffer); // Location of the crop origin x
        crop_y = y - (radius + buffer); // Location of the crop origin y
        
        cropRegion = cv::Rect(crop_x, crop_y, 2 * (radius + buffer), 2 * (radius + buffer));
        cropTube = image(cropRegion);
    }
    else {
        cerr << "Circle not possible!!!" << endl;
        return approx;
    }
    
    cvtColor(cropTube, cvtTube, CV_BGR2HSV);
    split(cvtTube, channels);
    
    foundCircles = OpenCVCircles::detectCirclesReturnVector(channels[1],
                                                            this->houghParams.dp,
                                                            this->houghParams.min_dist,
                                                            (int)this->houghParams.param_1 * 0.5,
                                                            (int)this->houghParams.param_2 * 0.5,
                                                            this->houghParams.min_radius,
                                                            this->houghParams.max_radius);
    
    
    // If HoughCircle algorithm can't find any circle
    if (foundCircles.size() < 1) {
        cout << "Didn't find a better circle" << endl;
        // Returns the original tap with the average radius (of the platform)
        return approx;
    }
    else {
        cout << "Found a better circle!" << endl;
        newCircle = foundCircles[0];
        newCircle[0] += crop_x;
        newCircle[1] += crop_y;
        return newCircle;
    }
}

Vec3f CircleSegment::findCircleFromCGFloats(CGFloat x, CGFloat y) {
    Vec3f newCircle((float)x,
                    (float)y,
                    (this->houghParams.min_radius + this->houghParams.max_radius)/2);
    
    newCircle = findOneCircle(newCircle);
    
    this->circles.push_back(newCircle);
    return newCircle;
}















