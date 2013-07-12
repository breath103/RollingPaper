#import "UIColor+Vingle.h"

@implementation UIColor (Vingle)
+ (UIColor *)mediumGray
{
    return [UIColor colorWithWhite:153.f/255.f alpha:1.f];
}
+ (UIColor *)highlightUnderlineColor
{
    return UIColorRGB(102, 102, 102);
}
+ (UIColor *)heavyGray
{
    return UIColorW(51);
}
+ (UIColor *)superlightGray
{
    return UIColorW(245);
}
+ (UIColor *)vingleRed
{
    return UIColorRGB(169, 3, 21);
}
@end
