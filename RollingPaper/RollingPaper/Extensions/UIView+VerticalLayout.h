#import <UIKit/UIKit.h>

#define KEYBOARD_HEIGHT 216.0f

@interface UIView(VerticalLayout)
- (void)setHeightWithSubviews;
- (float)getSubviewsTotalHeight;
- (void)addSubviewAtBottom:(UIView *)view withMargin:(float)margin;
- (void)addSubviewAtBottom:(UIView *)view;
- (void)setTopBelowOnlyVisible:(UIView *)view margin:(float)margin;
- (void)setTopBelowOnlyVisible:(UIView *)view;
- (void)setTopBelow:(UIView *)view margin:(float)margin;
- (void)setTopBelow:(UIView *)view;
- (void)setLeftAfter:(UIView *)view margin:(float)margin;
- (void)setLeftAfter:(UIView*)view;
- (CGFloat) getWidth;
- (CGFloat) getHeight;
- (CGFloat) getVisibleHeight;
- (CGFloat) getTop;
- (CGFloat) getBottom;
- (CGFloat) getLeft;
- (CGFloat) getRight;
- (void)setTop:(CGFloat)top;
- (void)setLeft:(CGFloat)left;
- (void)setRight:(CGFloat)right;
- (void)setBottom:(CGFloat)bottom;
- (void)setHeight:(CGFloat)height;
- (void)setWidth:(CGFloat)width;
- (void)setOrigin:(CGPoint)origin;
- (void)setSize:(CGSize)size;
- (void)sizeWidthToFit;
- (void)sizeHeightToFit;
- (void)addRelativeVGuide:(CGFloat)offset;
- (void)addRelativeHGuide:(CGFloat)offset;
- (void)addVGuide:(CGFloat)offset;
- (void)addHGuide:(CGFloat)offset;

@end
