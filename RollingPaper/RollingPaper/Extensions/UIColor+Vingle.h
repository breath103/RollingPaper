#import <UIKit/UIKit.h>

#define UIColorRGBA(r,g,b,a)  [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define UIColorRGB(r,g,b)     UIColorRGBA(r,g,b,1.0f)
#define UIColorWA(w,a)        UIColorRGBA(w,w,w,a)
#define UIColorW(w)           UIColorWA(w,1.0f)

@interface UIColor (Vingle)
+ (UIColor *)mediumGray;
+ (UIColor *)highlightUnderlineColor;
+ (UIColor *)vingleRed;
+ (UIColor *)superlightGray;
+ (UIColor *)heavyGray;
@end
