#import "LoadingTableViewCell.h"
#import "UIView+VerticalLayout.h"

@implementation LoadingTableViewCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIActivityIndicatorView* indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [indicatorView setCenter:CGPointMake([self getWidth]/2, [self getHeight]/2)];
        [indicatorView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|
         UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
        [indicatorView startAnimating];
        [self addSubview:indicatorView];
    }
    return self;
}
@end
