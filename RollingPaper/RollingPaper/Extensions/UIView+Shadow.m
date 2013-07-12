#import "UIView+Shadow.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (Shadow)

- (void) addShadow:(UIColor *)color
           opacity:(CGFloat) opacity
            offset:(CGSize) offset
            radius:(CGFloat) radius
{
    [[self layer] setShadowColor:color.CGColor];
    [[self layer] setShadowOpacity:opacity];
    [[self layer] setShadowOffset:offset];
    [[self layer] setShadowRadius:radius];
}

- (void) addBottomDropShadow:(float)radius
                       color:(UIColor *)color
                    distance:(CGFloat) distance
{
    CGRect bottomLine = self.bounds;
    bottomLine.origin.y = bottomLine.size.height;
    bottomLine.size.height = 1;
    CGPathRef path = [[UIBezierPath bezierPathWithRect:bottomLine] CGPath];
    [[self layer] setShadowPath:path];
    
    [[self layer] setShadowColor:[color CGColor]];
    [[self layer] setShadowOpacity:1.0];
    [[self layer] setShadowOffset:CGSizeMake(0, 0)];
    [[self layer] setShadowRadius:radius];
}

- (void) addBottomDropShadow
{
    [self addBottomDropShadow:0.5f color:UIColorWA(0, 0.3) distance:0];
}
- (void) addTopDropShadow
{
    CGRect bottomLine = self.bounds;
    bottomLine.origin.y    = 0;
    bottomLine.size.height = 1;
    CGPathRef path = [[UIBezierPath bezierPathWithRect:bottomLine] CGPath];
    [[self layer] setShadowPath:path];
    
    [[self layer] setShadowColor:UIColorWA(0, 0.5).CGColor];
    [[self layer] setShadowOpacity:1.0];
    [[self layer] setShadowOffset:CGSizeMake(0, 0)];
    [[self layer] setShadowRadius:2.0f  ];
}

- (void) addThumbnailCellDropShadow
{
    self.layer.shadowOffset = CGSizeMake(1.0, 1.0);
    self.layer.shadowRadius = 0.5;
    self.layer.shadowOpacity = 0.2;
}

- (void) addUltraThinBorder
{
    [[self layer] setCornerRadius : 2.0f];
    [[self layer] setBorderWidth : 0.5f];
    [[self layer] setBorderColor : UIColorW(204).CGColor];
}


@end
