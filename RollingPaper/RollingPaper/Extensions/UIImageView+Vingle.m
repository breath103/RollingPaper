#import "UIImageView+Vingle.h"
#import "AFImageRequestOperation.h"
#import <UIImageView+AFNetworking.h>
#import "UIImage+animatedGIF.h"
#import "UIImageView+AFNetworking.h"
#import "UIView+AnimationMacro.h"
#import "UIView+NibSupport.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+VerticalLayout.h"


#define CARD_INFO_PADDING 6.f
#define CARD_IMAGE_COUNT_LABEL_WIDTH 10.f

@implementation UIImageView (Vingle)

- (void)setImageWithURL:(NSString *)url
             withFadeIn:(NSTimeInterval)timeInterval
     doFadeInWithCached:(BOOL)doFadeInWithCachedImage
                success:(void(^)(BOOL isCached,UIImage *image))success
                failure:(void(^)(NSError *error))failure
{
    UIImageView *this = self;
    [self setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]
    placeholderImage:NULL
    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image){
        BOOL isCached = !request;
        if (timeInterval > 0) {
            if (!isCached || (isCached && doFadeInWithCachedImage)) {
                [this hideToTransparent];
                [this fadeIn:timeInterval];
            } else {
                [this showFromTransparent];
            }
        } else {
            [this showFromTransparent];
        }
        [this setImage:image];
        [this setNeedsDisplay];
        if(success)
            success(isCached,image);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        if(failure)
            failure(error);
    }];
}

- (void)setImageWithURL:(NSString *)url
             withFadeIn:(NSTimeInterval) timeInterval
                success:(void(^)(BOOL isCached,UIImage *image)) success
                failure:(void(^)(NSError *error)) failure{
    [self setImageWithURL:url
               withFadeIn:timeInterval
       doFadeInWithCached:NO
                  success:success
                  failure:failure];
}

- (void)setImageWithURL:(NSString *) url
             withFadeIn:(NSTimeInterval) timeInterval{
    [self setImageWithURL:url
               withFadeIn:timeInterval
                  success:nil
                  failure:nil];
}


- (void)setImageWithURL:(NSString *)url
                success:(void(^)(BOOL isCached,UIImage *image))success
                failure:(void(^)(NSError *error))failure{
    [self setImageWithURL:url
               withFadeIn:-1
       doFadeInWithCached:NO
                  success:success
                  failure:failure];
}


@end
