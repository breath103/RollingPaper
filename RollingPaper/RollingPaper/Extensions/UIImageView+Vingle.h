#import <UIKit/UIKit.h>

#define PLAY_ICON_VIEW_TAG 1341

@class Card;
@class VResource;

@interface UIImageView (Vingle)

- (void)setImageWithURL:(NSString *) url
             withFadeIn:(NSTimeInterval) timeInterval
     doFadeInWithCached:(BOOL) doFadeInWithCachedImage
                success:(void(^)(BOOL isCached,UIImage *image)) success
                failure:(void(^)(NSError *error)) failure;

- (void)setImageWithURL:(NSString *) url
             withFadeIn:(NSTimeInterval) timeInterval
                success:(void(^)(BOOL isCached,UIImage *image)) success
                failure:(void(^)(NSError *error)) failure;

- (void)setImageWithURL:(NSString *) url
             withFadeIn:(NSTimeInterval) timeInterval;

- (void)setImageWithURL:(NSString *) url
                success:(void(^)(BOOL isCached,UIImage *image)) success
                failure:(void(^)(NSError *error)) failure;

@end
