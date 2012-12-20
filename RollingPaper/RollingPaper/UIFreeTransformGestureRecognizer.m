//
//  UIFreeTransformGestureRecognizer.m
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 15..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "UIFreeTransformGestureRecognizer.h"
#import "CGPointExtension.h"

@implementation UIFreeTransformGestureRecognizer
@synthesize translation;
@synthesize rotation;
@synthesize scale;
- (id) initWithTarget:(id)target action:(SEL)action{
    self = [super initWithTarget:target action:action];
    if(self){
        [self reset];
    }
    return self;
}
- (void)ignoreTouch:(UITouch*)touch forEvent:(UIEvent*)event{
    
}// if a touch isn't part of this gesture it can be passed to this method to be ignored. ignored touches won't be cancelled on the view even if cancelsTouchesInView is YES

// the following methods are to be overridden by subclasses of UIGestureRecognizer
// if you override one you must call super

// called automatically by the runtime after the gesture state has been set to UIGestureRecognizerStateEnded
// any internal state should be reset to prepare for a new attempt to recognize the gesture
// after this is received all remaining active touches will be ignored (no further updates will be received for touches that had already begun but haven't ended)
- (void)reset{
    self.translation = CGPointZero;
    self.rotation    = 0.0f;
    self.scale       = 1.0f;
}

// same behavior as the equivalent delegate methods, but can be used by subclasses to define class-wide prevention rules
// for example, a UITapGestureRecognizer never prevents another UITapGestureRecognizer with a higher tap count
//- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer;
//- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer;

-(CGPoint) currentMiddlePointOfTouches : (NSSet*) touches{
    CGPoint middlePoint = CGPointZero;
    for(UITouch* touch in touches){
        CGPoint point = [touch locationInView:self.view];
        middlePoint = ccpAdd(middlePoint, point);
    }
    ccpMult(middlePoint, 1.0f / touches.count);
    return middlePoint;
}
-(CGPoint) prevMiddlePointOfTouches : (NSSet*) touches{
    CGPoint middlePoint = CGPointZero;
    for(UITouch* touch in touches){
        CGPoint point = [touch previousLocationInView:self.view];
        middlePoint = ccpAdd(middlePoint, point);
    }
    ccpMult(middlePoint, 1.0f / touches.count);
    return middlePoint;
}
-(CGFloat) scaleFromTouches : (NSSet*) touches{
    UITouch* touch1 = [[touches allObjects] objectAtIndex:0];
    UITouch* touch2 = [[touches allObjects] objectAtIndex:1];
    CGFloat currentDistance  = ccpDistance([touch1 locationInView:self.view],
                                           [touch2 locationInView:self.view]);
    CGFloat previousDistance = ccpDistance([touch1 previousLocationInView:self.view],
                                           [touch2 previousLocationInView:self.view]);
    return currentDistance / previousDistance;
}
-(CGFloat) rotationFromTouches : (NSSet*) touches{
    UITouch* touch1 = [[touches allObjects] objectAtIndex:0];
    UITouch* touch2 = [[touches allObjects] objectAtIndex:1];
    CGPoint previousDifference = ccpSub([touch1 previousLocationInView:self.view],
                                        [touch2 previousLocationInView:self.view]);
    CGPoint currentDifference  = ccpSub([touch1 locationInView:self.view],
                                        [touch2 locationInView:self.view]);
    CGFloat previousRotation = acos(previousDifference.x / ccpLength(previousDifference));
    if (previousDifference.y < 0) previousRotation *= -1;
    CGFloat currentRotation = acos(currentDifference.x / ccpLength(currentDifference));
    if (currentDifference.y < 0) currentRotation *= -1;
    return currentRotation - previousRotation;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    
    if(touches.count > 2){
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    self.state = UIGestureRecognizerStateBegan;
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    
    if (self.state == UIGestureRecognizerStateFailed)
        return;
    
    CGPoint delta = ccpSub([self currentMiddlePointOfTouches : event.allTouches],
                           [self prevMiddlePointOfTouches    : event.allTouches]);
    self.translation = ccpAdd(self.translation, delta);
    
    if(event.allTouches.count >= 2){
        self.scale    *= [self scaleFromTouches:event.allTouches];
        self.rotation += [self rotationFromTouches:event.allTouches];
    }
    
    self.state = UIGestureRecognizerStateChanged;
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    
    if(event.allTouches.count < 1){
        self.state = UIGestureRecognizerStateEnded;
    }
    else{
        //2손가락 이상으로 터치하다가 몇개를 땐 경우
        isTouchChanged = TRUE;
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesCancelled:touches withEvent:event];
 
    if(event.allTouches.count < 1){
        self.state = UIGestureRecognizerStateCancelled;
    }

}
-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}
@end
