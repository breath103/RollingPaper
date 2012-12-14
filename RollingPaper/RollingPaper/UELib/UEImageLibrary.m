//
//  UEImageLibrary.m
//  Madeleine
//
//  Created by 상현 이 on 12. 3. 21..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "UEImageLibrary.h"
#import <QuartzCore/QuartzCore.h>

@implementation UEImageLibrary


+(UIImage*) imageWithURL : (NSString*) url{
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
}
+(UIImage*) imageFromAssetRepresentation:(ALAssetRepresentation*) assetRep
{
    return [UEImageLibrary scaleAndRotateImage:[UIImage imageWithCGImage:assetRep.fullResolutionImage]
                                   orientation:[UEImageLibrary irUIImageOrientationFromAssetOrientation:assetRep.orientation]];
}

+(UIImage*) scaleImage : (UIImage*) originalImage
            resizeSize : (CGSize) aResizeSize 
{

    UIGraphicsBeginImageContext(CGSizeMake(aResizeSize.width, aResizeSize.height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0.0, aResizeSize.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, aResizeSize.width, aResizeSize.height), [originalImage CGImage]);
    UIImage* trasfromedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return trasfromedImage;
}

+(UIImage*) scaleAndRotateImage : (UIImage*) image
                    orientation : (UIImageOrientation) imageOrientation
{
    int kMaxResolution = 640; // Or whatever
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = imageOrientation;
    
    NSLog(@"%d",orient);
    switch(orient) {
            case UIImageOrientationUp: //EXIF = 1
                transform = CGAffineTransformIdentity;
                break;
            case UIImageOrientationUpMirrored: //EXIF = 2
                transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
                transform = CGAffineTransformScale(transform, -1.0, 1.0);
                break;
            
            case UIImageOrientationDown: //EXIF = 3
                transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
                transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
            case UIImageOrientationDownMirrored: //EXIF = 4
                transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
                transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
            case UIImageOrientationLeftMirrored: //EXIF = 5
                boundHeight = bounds.size.height;
                bounds.size.height = bounds.size.width;
                bounds.size.width = boundHeight;
                transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
                transform = CGAffineTransformScale(transform, -1.0, 1.0);
                transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
            case UIImageOrientationLeft: //EXIF = 6
                boundHeight = bounds.size.height;
                bounds.size.height = bounds.size.width;
                bounds.size.width = boundHeight;
                transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
                transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
            case UIImageOrientationRightMirrored: //EXIF = 7
                boundHeight = bounds.size.height;
                bounds.size.height = bounds.size.width;
                bounds.size.width = boundHeight;
                transform = CGAffineTransformMakeScale(-1.0, 1.0);
                transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
            case UIImageOrientationRight: //EXIF = 8
                boundHeight = bounds.size.height;
                bounds.size.height = bounds.size.width;
                bounds.size.width = boundHeight;
                transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
                transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
            default:
                [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
        }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}
+(UIImageOrientation) irUIImageOrientationFromAssetOrientation : (ALAssetOrientation) anOrientation {
    
	static UIImageOrientation assetOrientationsToImageOrientations[] = (UIImageOrientation[]){
		[ALAssetOrientationUp]          = UIImageOrientationUp,
		[ALAssetOrientationDown]        = UIImageOrientationDown,
		[ALAssetOrientationLeft]        = UIImageOrientationLeft,
		[ALAssetOrientationRight]       = UIImageOrientationRight,
		[ALAssetOrientationUpMirrored]  = UIImageOrientationUpMirrored,
		[ALAssetOrientationDownMirrored] = UIImageOrientationDownMirrored,
		[ALAssetOrientationLeftMirrored] = UIImageOrientationLeftMirrored,
		[ALAssetOrientationRightMirrored] = UIImageOrientationRightMirrored
	};
    
	return assetOrientationsToImageOrientations[anOrientation];
    
}
+(UIImage*) convertToJPEG : (UIImage*) image
                withScale : (double) compressionScale
{
    NSData* jpegImage = UIImageJPEGRepresentation(image, compressionScale);
    return [UIImage imageWithData:jpegImage];
}
+(UIImage*) imageFromView : (UIView*) view{
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);
 
    return viewImage;
}
+(BOOL) saveImage : (UIImage*) image
           ToFile : (NSString*) fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) ;
    NSString *imagePath = [paths objectAtIndex:0] ;
    NSString *filepath  = [NSString stringWithFormat:@"%@/%@", imagePath, fileName] ;

    NSData *imageData   = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0f)];
    [imageData writeToFile:filepath atomically:YES];
    return TRUE;
}
@end
