//
//  macro.h
//  Ryokan
//
//  Created by ANTH on 11. 12. 20..
//  Copyright (c) 2011년 TwinMoon. All rights reserved.
//

#ifndef Ryokan_macro_h
#define Ryokan_macro_h

#import <UIKit/UIKit.h>
#define ARC4RANDOM_MAX      0x100000000


#define FLOAT_TO_NSNUMBER(f) ([NSNumber numberWithFloat:(f)])

#define APP_SCALE ([[UIScreen mainScreen] scale])
#define APP_SCALE_TRANSFORM (CGAffineTransformMakeScale(APP_SCALE,APP_SCALE))
#define APP_SCALE_I_TRANSFORM (CGAffineTransformMakeScale(1.0f/APP_SCALE,1.0f/APP_SCALE)) 
#define UIBoundsToCGBounds(r) (CGRectApplyAffineTransform(r,APP_SCALE_TRANSFORM))
#define CGBoundsToUIBounds(r) (CGRectApplyAffineTransform(r,APP_SCALE_I_TRANSFORM))
#define UIColorRGBA(r,g,b,a) [UIColor colorWithRed:r green:g blue:b alpha:a]
#define UIColorRGB(r,g,b) UIColorRGBA(r,g,b,1.0f)
#define UIColorXRGB(r,g,b) UIColorRGBA(r/255.0f,g/255.0f,b/255.0f,1.0f)
#define KEYBOARD_HEIGHT (216.0f)
#define DEBUG_NETWORK_NOT_AVAILABLE
#define ToNSURL(x) ([[NSURL alloc]initWithString:x])
#define ToNSURLRequest(x) ([NSURLRequest requestWithURL:ToNSURL(x)])



CGPoint CGPointRotateWithCenter( CGPoint p1 ,CGPoint center,float angle_radian);
CGPoint CGPointAdd(CGPoint p1,CGPoint p2); 
CGPoint CGPointSubtract(CGPoint p1,CGPoint p2);
CGPoint CGPointMultiply(CGPoint p1,float f);
CGPoint CGPointNormalize(CGPoint p1);
float   CGPointDot(CGPoint p1,CGPoint p2);
float   CGPointLength(CGPoint p);
float   CGPointDistance(CGPoint p1,CGPoint p2);
float   CGPointCross(CGPoint p1,CGPoint p2);
float   CGPointTheta(CGPoint v1,CGPoint v2);
float 	CGPointThetaWithBasis(CGPoint v1);
BOOL	CGRectPointIntersect(CGRect rect,CGPoint p1);
float   Lerp(float f1,float f2,float scale);
CGPoint CGRectCenter(CGRect rect);
void    setViewFrameByCenterPos( UIView* view,CGPoint center);
NSMutableArray* ImagesWithFormatString( NSString* formatString,int minIndex,int maxIndex);
int 	randRange(int min,int max) ;
double  randFloat();

//CGPoint  CGRectMake(CGPoint p,CGSize s);

void 	UIViewSetX(UIView* view, int x);
void 	UIViewSetY(UIView* view, int y);
void 	UIViewSetOrigin(UIView* view, CGPoint origin);
void 	UIViewSetWidth(UIView* view, int width);
void 	UIViewSetHeight(UIView* view, int height);
void 	UIViewSetSize(UIView* view, CGSize size);
void    ShowAlertView(NSString* title,NSString* message,NSString* button1,NSString* button2);

UIView* ReadNib( NSString* name,NSObject* owner);

NSManagedObjectContext* getDefaultManagedObjectContext();

NSDictionary* parseJSON(NSString* str);

@interface NSDictionary (StringMacro)
-(NSString*) stringForKey : (id) key;
@end

@interface UIViewController(NibMacro)
-(id) initWithDefaultNib;
@end


#ifndef BETWEEN//(min,x,max) 
	#define BETWEEN(min,x,max) ( min<=x&&x<=max ) 
#endif

#endif
