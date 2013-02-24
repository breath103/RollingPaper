//
//  UEUI.h
//  Madeleine
//
//  Created by 상현 이 on 12. 4. 3..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UEKeyboardBackgroundButton : UIButton
@property (nonatomic,weak) UIView* targetView;
-(id) initWithTargetView: (UIView*) view;
-(IBAction)onTouched:(id)sender;
@end





struct UEUIMargin
{
    int left;
    int top;
    int right;
    int bottom;
};
typedef struct UEUIMargin UEUIMargin;


@interface UEUIGrid : NSObject
@property (nonatomic,assign) int gridWidth;
@property (nonatomic,assign) int gridHeight;
@property (nonatomic,assign) CGSize cellSize;
@property (nonatomic,assign) UEUIMargin cellMargin;
@property (nonatomic,assign) UEUIMargin gridOffset;
@property (nonatomic,assign) float verticalLineWidth;
@property (nonatomic,assign) float horizontalLineWidth;
-(id) initWithGridWidth : (int) gridWidth 
                 height : (int) gridHeight
               cellSize : (CGSize) cellSize;
-(CGRect) getCellAtIndex : (int) index;
@end 


@interface UEUI : NSObject
+(CGColorRef) CGColorWithRed : (CGFloat) red
                       Green : (CGFloat) green
                        Blue : (CGFloat) blue
                       Alpha : (CGFloat) alpha;
+(void) ziggleAnimation : (UIView*) view;
+(void) createKeyboardButton : (UIView*) rootView : (UIView*) targetView;
+(void) animateViewsToFitKeyboard : (UIView*) view ;
+(void) CGAffineTransformWithTouches : (UITouch *) firstTouch
                                      secondTouch : (UITouch *) secondTouch
                                            scale : (CGSize*) size
                                         rotation : (NSNumber**) rotation;
+(CGAffineTransform) CGAffineTransformWithTouches : (CGAffineTransform) oldTransform
                                       firstTouch : (UITouch *) firstTouch
                                      secondTouch : (UITouch *) secondTouch;
@end


@interface UIView(AnimationMacro)
-(void) hideToTransparent;
-(void) fadeIn : (float) duration;
-(void) fadeTo : (float) alpha
      duration : (float) duration;
-(void) fadeOut : (float) duration;
-(BOOL) fadeToggle : (float) duration;
@end







