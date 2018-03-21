//
//  CircleSegment.cpp
//  Optical Assay
//
//  Created by Derek Nguyen on 2/25/18.
//  Copyright © 2018 Optical Assay Team. All rights reserved.
//

#include <opencv2/highgui/highgui.hpp>
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
        
        // Check to make sure position X and Y not < 0
        //  width and height of circle does not exceed width and height of picture.
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
        
        // Store cropped region of the image
        // Increase the size (automatic reallocation) of the allocated storage through push_back()
        (*crops_dest).push_back(image_src(cropRegion).clone());
        
        // TODO: Save this image
        
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
    
    
    // TODO: Tweak Structing element
    kernel = getStructuringElement(MORPH_ELLIPSE, cv::Size(5, 5), cv::Point(0, 0));
    
    // Perform thresholding
    for (int i = 0; i < tubes_src.size(); i++) {
        threshold(bw_tubes[i], result, 0, 255, CV_THRESH_BINARY | CV_THRESH_OTSU);
        bitwise_not(result, result);
        erode(result, result, kernel);
        
        (*masks_dest).push_back(result.clone());
    }
}

// Perform a bitwise_and on all of the masks and crops
void CircleSegment::applyMasks(vector<Mat> *masks_src, vector<Mat> *crops_src, vector<Mat> *result_dest) {
    Mat result, temp;
    
    for (int i = 0; i < (*masks_src).size(); i++) {
        
        cvtColor((*masks_src)[i], temp, CV_GRAY2BGR);
        bitwise_and((*crops_src)[i], temp, result);
        
        (*result_dest).push_back(result.clone());
    }
}

// Derive some basic statistical data from images & filter out bad wells
void CircleSegment::getStats(vector<Mat> solutionPixels_src, vector<Mat> masks_src, vector<CircleSegment::ImageStats> *results_dest) {
    Mat convertedImage;
    
    for (int i = 0; i < solutionPixels_src.size(); i++) {
        cout << "Number " << i << endl;
        (*results_dest).push_back(ImageStats());
        
        // bgr stats
        meanStdDev(solutionPixels_src[i], (*results_dest)[i].bgrMean, (*results_dest)[i].bgrStdv, masks_src[i]);
        cout << "bgr " << (*results_dest)[i].bgrMean << endl;
        
        // hsv stats
        cvtColor(solutionPixels_src[i], convertedImage, CV_BGR2HSV);
        meanStdDev(convertedImage, (*results_dest)[i].hsvMean, (*results_dest)[i].hsvStdv, masks_src[i]);
        cout << "hsv (use Hue as result) " << (*results_dest)[i].hsvMean << endl;
        
        // CIE_Luv
        cvtColor(solutionPixels_src[i], convertedImage, CV_BGR2Luv);
        meanStdDev(convertedImage, (*results_dest)[i].luvMean, (*results_dest)[i].luvStdv, masks_src[i]);
        cout << "luv " << (*results_dest)[i].luvMean << endl;
        
        // YCrCb
        cvtColor(solutionPixels_src[i], convertedImage, CV_BGR2YCrCb);
        meanStdDev(convertedImage, (*results_dest)[i].ycrcbMean, (*results_dest)[i].ycrcbStdv, masks_src[i]);
        cout << "ycrcb " << (*results_dest)[i].ycrcbMean << endl;
        
        // Put tube thresholding conditions here
        (*results_dest)[i].img = solutionPixels_src[i];
        (*results_dest)[i].circleInfo = this->circles[i];
        cout << "circle " << (*results_dest)[i].circleInfo << endl << endl;
        
    }
}

vector<CircleSegment::ImageStats> CircleSegment::performAnalysis(vector<Vec3f> circles) {
    this->circles = circles;
    cout << "1: Got circles " << this->circles.size() << endl;
    
    vector<Mat> crops; crops.reserve(this->circles.size());
    vector<Mat> masks; masks.reserve(this->circles.size());
    vector<Mat> solut; solut.reserve(this->circles.size());
    vector<Mat> temps; temps.reserve(this->circles.size());
    vector<CircleSegment::ImageStats> imageStats; imageStats.reserve(this->circles.size());
    
    cropTubes(this->image, &crops);
    cout << "2: Made crops " << crops.size() << endl;
    
    makeMasks(crops, &masks);
    cout << "3: Made masks " << masks.size() << endl;
    
    applyMasks(&masks, &crops, &solut);
    cout << "4: Applied masks " << solut.size() << endl;
    
    getStats(solut, masks, &imageStats);
    cout << "5: Number of circles " << imageStats.size() << endl;
    
    return imageStats;
}

void chooseParams(CircleSegment::PhoneModel phone, CircleSegment::HoughParameters *hp) {
    /*
     HoughCircles( src_gray, circles, CV_HOUGH_GRADIENT, 1, src_gray.rows/8, 200, 100, 0, 0 );
     
     with the arguments:
     src_gray: Input image (grayscale)
     circles: A vector that stores sets of 3 values: x_{c}, y_{c}, r for each detected circle.
     CV_HOUGH_GRADIENT: Define the detection method. Currently this is the only one available in OpenCV
     dp = 1: The inverse ratio of resolution
     min_dist = src_gray.rows/8: Minimum distance between detected centers
     param_1 = 200: Upper threshold for the internal Canny edge detector
     param_2 = 100*: Threshold for center detection.
     min_radius = 0: Minimum radio to be detected. If unknown, put zero as default.
     max_radius = 0: Maximum radius to be detected. If unknown, put zero as default
     */
    switch (phone) {
//        case CircleSegment::iPhone5c:
//            hp->dp = 1;
//            hp->mind_ist = 120;
//            hp->param_1 = 100.1;
//            hp->param_2 = 31.1;
//            hp->min_radius = 40;
//            hp->max_radius = 70;
//            break;
        case CircleSegment::iPhoneX:
            hp->dp = 1;
            hp->min_dist = 50;
            hp->param_1 = 99;
            hp->param_2 = 31;
            hp->min_radius = 70;
            hp->max_radius = 140;
            break;
        default:
            // MARK: Possible fix for hough circle parameters
            cerr << "Did not select iPhone model, iPhone5s default" << endl;
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
    chooseParams(CircleSegment::iPhoneX, &(this->houghParams));
    
    Mat saturation = channels[1];
    
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
    Mat channels[4];
    Mat cvtTube, cropTube;
    cv::Rect cropRegion;
    vector<Vec3f> foundCircles;
    Vec3f newCircle;
    float dx, dy; // Location of the crop region
    float x = approx[0];
    float y = approx[1];
    float radius = approx[2];
    
    const int buffer = 30;
    
    // Make sure the crop zone is possible before cropping
    if (x - (radius + buffer) > 0 &&
        y - (radius + buffer) > 0 &&
        x - (radius + buffer) + 2 * (radius + buffer) < (this->image).cols &&
        y - (radius + buffer) + 2 * (radius + buffer) < (this->image).rows) {
        
        dx = x - (radius + buffer);
        dy = y - (radius + buffer);
        cropRegion = cv::Rect(dx, dy, 2 * (radius + buffer), 2 * (radius + buffer));
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
                                                            this->houghParams.param_1 * 0.5,
                                                            this->houghParams.param_2 * 0.5,
                                                            this->houghParams.min_radius,
                                                            this->houghParams.max_radius);
    
    if (foundCircles.size() < 1) {
        cout << "Didn't find a better circle" << endl;
        // Returns the original tap with the average radius (of the platform)
        return approx;
    }
    else {
        cout << "Found a better circle!" << endl;
        newCircle = foundCircles[0];
        newCircle[0] += dx;
        newCircle[1] += dy;
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















