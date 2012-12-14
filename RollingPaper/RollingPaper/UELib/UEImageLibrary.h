//
//  UEImageLibrary.h
//  Madeleine
//
//  Created by 상현 이 on 12. 3. 21..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>


@interface UEImageLibrary : NSObject
+(UIImage*) imageWithURL : (NSString*) url;
+(UIImage*) scaleImage : (UIImage*) originalImage
            resizeSize : (CGSize) aResizeSize;
+(UIImage*) imageFromAssetRepresentation:(ALAssetRepresentation*) assetRep;
+(UIImage*) scaleAndRotateImage : (UIImage*) image
                    orientation : (UIImageOrientation) imageOrientation;
+(UIImageOrientation) irUIImageOrientationFromAssetOrientation : (ALAssetOrientation) anOrientation;
+(UIImage*) convertToJPEG : (UIImage*) image
                withScale : (double) compressionScale;
+(UIImage*) imageFromView : (UIView*) view;
+(BOOL) saveImage : (UIImage*) image
           ToFile : (NSString*) fileName;
@end
