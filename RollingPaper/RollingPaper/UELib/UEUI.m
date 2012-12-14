//
//  UEUI.m
//  Madeleine
//
//  Created by 상현 이 on 12. 4. 3..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "UEUI.h"
#import "macro.h"
#import "ccMacros.h"
#import "CGPointExtension.h"
@implementation UEKeyboardBackgroundButton
@synthesize targetView;
-(id) initWithTargetView:(UIView *)view
{
    self = [self init];
    if(self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        self.targetView = view;
        [self addTarget:self action:@selector(onTouched:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}
-(IBAction)onTouched:(id)sender
{
    [targetView resignFirstResponder];
    [self removeFromSuperview];
}
@end



@implementation UEUIGrid
@synthesize gridWidth;
@synthesize gridHeight;
@synthesize gridOffset;
@synthesize cellSize;
@synthesize cellMargin;
@synthesize verticalLineWidth;
@synthesize horizontalLineWidth;
-(id) initWithGridWidth : (int) dGridWidth 
                 height : (int) dGridHeight
               cellSize : (CGSize) pCellSize
{
    self = [super init];
    if(self)
    {
        self.gridWidth  = dGridWidth;
        self.gridHeight = dGridHeight;
        self.cellSize   = pCellSize; 
    }
    return self;
}

-(CGRect) getCellAtIndex : (int) index
{
    if( index < 0 || index >= gridWidth * gridHeight)
    {
        return CGRectMake(0, 0, 0, 0);
    }
    
    return CGRectMake(gridOffset.left + (index % gridWidth)  * (cellMargin.left + cellSize.width  + cellMargin.right),
                      gridOffset.top  + (index / gridHeight) * (cellMargin.top  + cellSize.height + cellMargin.bottom),
                      cellSize.width,cellSize.height);
}
@end



@implementation UEUI
+(void) createKeyboardButton : (UIView*) rootView : (UIView*) targetView
{
    UEKeyboardBackgroundButton* bgButton = [[UEKeyboardBackgroundButton alloc] initWithTargetView:targetView];
    UIViewSetSize(bgButton,rootView.frame.size);

    [rootView addSubview:bgButton];
}

+(void) animateViewsToFitKeyboard : (UIView*) view 
{
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.3];
    [UIView beginAnimations:@"KeyboardAnimation" context:NULL];
        UIViewSetY(view, view.frame.origin.y - KEYBOARD_HEIGHT);
    [UIView commitAnimations];
}
+(void) CGAffineTransformWithTouches : (UITouch *) firstTouch
                                      secondTouch : (UITouch *) secondTouch
                                            scale : (CGSize*) size
                                         rotation : (NSNumber**) rotation
{
    CGPoint firstTouchLocation         = [firstTouch locationInView:nil];
    CGPoint firstTouchPreviousLocaion  = [firstTouch previousLocationInView:nil];
    CGPoint secondTouchLocation        = [secondTouch locationInView:nil];
    CGPoint secondTouchPreviousLocaion = [secondTouch previousLocationInView:nil];
    
    CGFloat currentDistance  = ccpDistance(firstTouchLocation,secondTouchLocation);
    CGFloat previousDistance = ccpDistance(firstTouchPreviousLocaion,secondTouchPreviousLocaion);
    
    CGFloat distanceRatio = currentDistance / previousDistance;
    
    size->width  = distanceRatio;
    size->height = distanceRatio;
    
    CGPoint previousDifference = ccpSub(firstTouchPreviousLocaion, secondTouchPreviousLocaion);
    CGFloat xDifferencePrevious = previousDifference.x;
    
    CGFloat previousRotation = acos(xDifferencePrevious / previousDistance);
    if (previousDifference.y < 0) {
        previousRotation *= -1;
    }
    
    CGPoint currentDifference = ccpSub(firstTouchLocation, secondTouchLocation);
    CGFloat xDifferenceCurrent = currentDifference.x;
    
    CGFloat currentRotation = acos(xDifferenceCurrent / currentDistance);
    if (currentDifference.y < 0) {
        currentRotation *= -1;
    }
    
    CGFloat newAngle = currentRotation - previousRotation;
    
    (*rotation) = [NSNumber numberWithDouble:newAngle];
}
+(CGAffineTransform) CGAffineTransformWithTouches : (CGAffineTransform) oldTransform
                                       firstTouch : (UITouch *) firstTouch
                                      secondTouch : (UITouch *) secondTouch{
    
    CGPoint firstTouchLocation         = [firstTouch locationInView:nil];
    CGPoint firstTouchPreviousLocaion  = [firstTouch previousLocationInView:nil];
    CGPoint secondTouchLocation        = [secondTouch locationInView:nil];
    CGPoint secondTouchPreviousLocaion = [secondTouch previousLocationInView:nil];
    
    CGAffineTransform newTransform;
    
    CGFloat currentDistance  = ccpDistance(firstTouchLocation,secondTouchLocation);
    CGFloat previousDistance = ccpDistance(firstTouchPreviousLocaion,secondTouchPreviousLocaion);
    
    CGFloat distanceRatio = currentDistance / previousDistance;
    
    newTransform = CGAffineTransformScale(oldTransform, distanceRatio, distanceRatio);
    
    CGPoint previousDifference = ccpSub(firstTouchPreviousLocaion, secondTouchPreviousLocaion);
    CGFloat xDifferencePrevious = previousDifference.x;
    
    CGFloat previousRotation = acos(xDifferencePrevious / previousDistance);
    if (previousDifference.y < 0) {
        previousRotation *= -1;
    }
    
    CGPoint currentDifference = ccpSub(firstTouchLocation, secondTouchLocation);
    CGFloat xDifferenceCurrent = currentDifference.x;
    
    CGFloat currentRotation = acos(xDifferenceCurrent / currentDistance);
    if (currentDifference.y < 0) {
        currentRotation *= -1;
    }
    
    CGFloat newAngle = currentRotation - previousRotation;
    
    newTransform = CGAffineTransformRotate(newTransform, newAngle);
    return newTransform;
}
@end
