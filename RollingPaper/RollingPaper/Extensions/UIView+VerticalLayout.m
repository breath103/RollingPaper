#import "UIView+VerticalLayout.h"

@implementation UIView(VerticalLayout)

- (void)setHeightWithSubviews
{
    CGRect frame = self.frame;
    frame.size.height = [self getSubviewsTotalHeight];
    self.frame = frame;
}

- (float)getSubviewsTotalHeight
{
    CGFloat subViewsTotalHeight = 0.0f;
    for (UIView* view in self.subviews) {
        if (!view.hidden) {
            CGFloat y = view.frame.origin.y;
            CGFloat h = view.frame.size.height;
            if (y + h > subViewsTotalHeight) {
                subViewsTotalHeight = h + y;
            }
        }
    }
    return subViewsTotalHeight;
}


- (void)addSubviewAtBottom:(UIView *) view withMargin:(float)margin {
    CGRect frame = view.frame;
    frame.origin.y = [self getSubviewsTotalHeight] + margin;
    [self addSubview:view];
    
}
- (void)addSubviewAtBottom:(UIView *)view {
    [self addSubviewAtBottom:view withMargin:0];
}

- (void)setTop : (CGFloat) top{
    CGRect frame = self.frame;
    frame.origin.y = top;
    self.frame = frame;
}
- (void)setLeft : (CGFloat) left{
    CGRect frame = self.frame;
    frame.origin.x = left;
    self.frame = frame;
}
- (void)setRight : (CGFloat) right{
    CGFloat newWidth = right - self.frame.origin.x;
    if(newWidth >= 0)
        [self setWidth:newWidth];
}
- (void)setBottom : (CGFloat) bottom{
    CGFloat newHeight = bottom - self.frame.origin.y;
    if(newHeight >= 0)
        [self setHeight:newHeight];
}
- (void)setTopBelow:(UIView *)view margin:(float)margin {
    CGRect frame = self.frame;
    frame.origin.y = view.frame.origin.y + view.frame.size.height + margin;
    self.frame = frame;
}
- (void)setTopBelowOnlyVisible:(UIView *)view margin:(float)margin
{
    CGRect frame = self.frame;
    frame.origin.y = view.frame.origin.y + (view.isHidden?0:view.frame.size.height) + margin;
    self.frame = frame;
}
- (void)setTopBelowOnlyVisible:(UIView *)view
{
    CGRect frame = self.frame;
    frame.origin.y = view.frame.origin.y + (view.isHidden?0:view.frame.size.height);
    self.frame = frame;
}


- (void)setTopBelow:(UIView *)view {
    [self setTopBelow:view margin:0];
}
- (void)setLeftAfter:(UIView*)view{
    [self setLeftAfter:view margin:0];
}
- (CGFloat) getBottom
{
    return self.frame.origin.y + self.frame.size.height;
}
- (CGFloat) getTop
{
    return self.frame.origin.y;
}
- (CGFloat) getWidth
{
    return self.frame.size.width;
}
- (CGFloat) getHeight
{
    return self.frame.size.height;
}
- (CGFloat) getVisibleHeight
{
    return self.isHidden?0:[self getHeight];
}

- (CGFloat) getLeft
{
    return self.frame.origin.x;
}
- (CGFloat) getRight
{
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setLeftAfter:(UIView*)view margin:(float)margin{
    CGRect frame= self.frame;
    frame.origin.x = view.frame.origin.x + view.frame.size.width + margin;
    self.frame = frame;
}
- (void)setHeight : (CGFloat) height{
    CGRect r = self.frame;
    r.size.height = height;
    self.frame = r;
}
- (void)setWidth : (CGFloat) width{
    CGRect r = self.frame;
    r.size.width = width;
    self.frame = r;
}

- (void)setOrigin : (CGPoint) origin
{
    CGRect r = self.frame;
    r.origin = origin;
    self.frame = r;
}
- (void)setSize:(CGSize)size
{
    CGRect r = self.frame;
    r.size = size;
    self.frame = r;
}

-(void) sizeWidthToFit
{
    CGFloat originalHeight = self.frame.size.height;
    CGSize newSize = [self sizeThatFits:CGSizeMake(CGFLOAT_MAX, originalHeight)];
    CGRect frame = self.frame;
    frame.size.width = newSize.width;
    self.frame = frame;
}
-(void) sizeHeightToFit
{
    CGFloat originalWidth = self.frame.size.width;
    CGSize newSize = [self sizeThatFits:CGSizeMake(originalWidth,CGFLOAT_MAX)];
    CGRect frame = self.frame;
    frame.size.height = newSize.height;
    self.frame = frame;
}

- (void)addRelativeVGuide:(CGFloat)offset
{
    static float relatvieVGuideOffset = 0;
    relatvieVGuideOffset += offset;
    [self addVGuide:relatvieVGuideOffset];
}

- (void)addRelativeHGuide:(CGFloat)offset
{
    static float relatvieHGuideOffset = 0;
    relatvieHGuideOffset += offset;
    NSLog(@"%f",relatvieHGuideOffset);
    [self addHGuide:relatvieHGuideOffset];
}

- (void)addVGuide:(CGFloat)offset
{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, [self getHeight])];
    [view setBackgroundColor:[UIColor blueColor]];
    [view setCenter:CGPointMake(offset, self.frame.size.height/2)];
    [self addSubview:view];
}
- (void)addHGuide:(CGFloat)offset
{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self getWidth], 1)];
    [view setBackgroundColor:[UIColor blueColor]];
    [view setCenter:CGPointMake(self.frame.size.width/2,offset)];
    [self addSubview:view];
}
@end


@implementation UILabel(VerticalLayout)

@end