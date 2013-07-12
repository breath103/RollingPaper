#import "UIImage+animatedGIF.h"
#import <ImageIO/ImageIO.h>
#import <ImageIO/CGImageSource.h>
#import <ImageIO/CGImageProperties.h>

#if __has_feature(objc_arc)
#define toCF (__bridge CFTypeRef)
#else
#define toCF (CFTypeRef)
#endif

@implementation UIImage (animatedGIF)



static UIImage *animatedImageWithAnimatedGIFImageSource(CGImageSourceRef source)
{
    if (!source)
        return nil;
    
    size_t count = CGImageSourceGetCount(source);
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:count];
    

    float totalduration = 0.0f;
    for (size_t i = 0; i < count; ++i) {
        CGImageRef cgImage = CGImageSourceCreateImageAtIndex(source, i, NULL);

        CFDictionaryRef imagePropertiesDictionary = CGImageSourceCopyPropertiesAtIndex(source,i,NULL);
        NSDictionary *gif_dict = (__bridge NSDictionary*)
                (CFDictionaryRef)CFDictionaryGetValue(imagePropertiesDictionary, kCGImagePropertyGIFDictionary);
        
        totalduration += [((NSString*)[gif_dict objectForKey:(__bridge NSString*)kCGImagePropertyGIFDelayTime]) floatValue];
        CFRelease(imagePropertiesDictionary);
        if (!cgImage)
            return nil;
        else {
            [images addObject:[UIImage imageWithCGImage:cgImage]];
            CGImageRelease(cgImage);
        }
    }

    return [UIImage animatedImageWithImages:images
                                   duration:totalduration];
}

static UIImage *animatedImageWithAnimatedGIFReleasingImageSource(CGImageSourceRef source)
{
    UIImage *image = animatedImageWithAnimatedGIFImageSource(source);
    return image;
}

+ (UIImage *)animatedImageWithAnimatedGIFData:(NSData *)data
{
    CGImageSourceRef source = CGImageSourceCreateWithData(toCF data, NULL);
    UIImage *image = animatedImageWithAnimatedGIFReleasingImageSource(source);
    if(source)
        CFRelease(source);
    return image;
}

+ (UIImage *)animatedImageWithAnimatedGIFURL:(NSURL *)url
{
    CGImageSourceRef source = CGImageSourceCreateWithURL(toCF url, NULL);
    UIImage *image = animatedImageWithAnimatedGIFReleasingImageSource(source);
    if(source)
        CFRelease(source);
    return image;
}

@end
