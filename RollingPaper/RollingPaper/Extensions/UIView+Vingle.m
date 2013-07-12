#import "UIView+Vingle.h"

@implementation UIView (Vingle)
- (void)disableScrollToTopForAllChilds
{
    if([self isKindOfClass:[UIScrollView class]])
        [((UIScrollView *)self) setScrollsToTop:NO];

    for(UIView *view in [self subviews]) {
        if([view isKindOfClass:[UIScrollView class]])
            [((UIScrollView *)view) setScrollsToTop:NO];

        [view disableScrollToTopForAllChilds];
    }
}
@end
