//
//  UIImage+OpenCV.mm
//  Optical Assay
//
//  Created by Derek Nguyen on 2/25/18.
//  Copyright © 2018 Optical Assay Team. All rights reserved.
//

#import "UIImage+OpenCV.h"

@implementation UIImage (OpenCV)

- (cv::Mat)CVMat {
    
    printf("(from UIImage+OpenCV.mm)\n\tCreating CVMat from UIImage\n\n");
    
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(self.CGImage);
    CGFloat cols = self.size.width;
    CGFloat rows = self.size.height;
    
    if  (self.imageOrientation == UIImageOrientationLeft || self.imageOrientation == UIImageOrientationRight) {
        cols = self.size.height;
        rows = self.size.width;
    }

    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), self.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

- (cv::Mat)CVMat3 {
    cv::Mat result = [self CVMat];
    cv::cvtColor(result , result , CV_RGBA2RGB);
    return result;
}

-(cv::Mat)CVGrayscaleMat {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGFloat cols = self.size.width;
    CGFloat rows = self.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), self.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;
}

+ (UIImage *)imageWithCVMat:(const cv::Mat&)cvMat orientation:(UIImageOrientation)orientation {
    return [[UIImage alloc] initWithCVMat:cvMat orientation:orientation];
}

- (id)initWithCVMat:(const cv::Mat&)mat orientation:(UIImageOrientation)orientation {
    
    NSLog(@"(from UIImage+OpenCV.mm) initWithCVMat");
    CGColorSpaceRef colorSpace;
    cv::Mat cvMat;
    
    std::cout << "Elements: " << mat.elemSize() << std::endl;
    if (mat.elemSize() == 1) {
        cvMat = mat;
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        cv::cvtColor(mat, cvMat, CV_BGR2RGB);
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize() * cvMat.total()];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                              //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    // Getting UIImage from CGImage
    self = [self initWithCGImage:imageRef];// scale:1 orientation:orientation];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return self;
}

@end
