#import <UIKit/UIKit.h>

@interface UIImageView (Vingle)
- (void)addActivtyIndicator;

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
