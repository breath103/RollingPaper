#import <UIKit/UIKit.h>

@interface UIView (Shadow)
- (void) addShadow:(UIColor *)color
           opacity:(CGFloat) opacity
            offset:(CGSize) offset
            radius:(CGFloat) radius;
- (void) addBottomDropShadow:(float)radius
                       color:(UIColor *)color
                    distance:(CGFloat) distance;
- (void) addBottomDropShadow;
- (void) addTopDropShadow;
- (void) addThumbnailCellDropShadow;
- (void) addUltraThinBorder;

@end
