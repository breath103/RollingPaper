//
//  File.c
//  Ryokan
//
//  Created by ANTH on 11. 12. 20..
//  Copyright (c) 2011년 TwinMoon. All rights reserved.
//


#include "macro.h"
#include <math.h>

#include "AppDelegate.h"


CGPoint CGPointRotateWithCenter( CGPoint p1 ,CGPoint center,float angle_radian)
{
	CGAffineTransform rotate_mat = CGAffineTransformMakeRotation(angle_radian);
	CGAffineTransform translate_mat = CGAffineTransformMakeTranslation(center.x,center.y);
	CGAffineTransform i_translate_mat = CGAffineTransformMakeTranslation(-center.x, -center.y);
	
	//중심점을 원점으로 이동시키고 회전시킨다음 다시 중심점을 복귀시킨다.
	CGAffineTransform transform = CGAffineTransformConcat(i_translate_mat,rotate_mat);
	transform = CGAffineTransformConcat(transform, translate_mat);
	
	return CGPointApplyAffineTransform(p1, transform);
}
CGPoint CGPointAdd(CGPoint p1,CGPoint p2)
{
	return CGPointMake(p1.x+p2.x, p1.y+p2.y);
}
CGPoint CGPointSubtract(CGPoint p1,CGPoint p2)
{
	return CGPointMake(p1.x-p2.x, p1.y-p2.y);
}
CGPoint CGPointMultiply(CGPoint p1,float f)
{
	return CGPointMake(p1.x*f, p1.y*f);
}
CGPoint CGPointNormalize(CGPoint p1)
{
	return CGPointMultiply(p1, 1/CGPointLength(p1));
}
float   CGPointDot(CGPoint p1,CGPoint p2)
{
	return (p1.x*p2.x + p1.y*p2.y);
}
float   CGPointLength(CGPoint p)
{
	return sqrt(p.x * p.x + p.y * p.y);	
}
float   CGPointDistance(CGPoint p1,CGPoint p2)
{
	return CGPointLength(CGPointSubtract(p1, p2));
}
float   CGPointCross(CGPoint p1,CGPoint p2) 
{
	return p1.x * p2.y - p1.y * p2.x;
}
float   CGPointTheta(CGPoint v1,CGPoint v2)
{
	float theta = acos(CGPointDot(v1,v2) / CGPointLength(v1) / CGPointLength(v2));
	if( CGPointCross(v1,v2) < 0 )
		theta *= -1;
	
	return theta;
}
float   CGPointThetaWithBasis(CGPoint v1)
{
	return atan2f(v1.x,v1.y);
}
float   Lerp(float f1,float f2,float scale)
{
	return f1 + (f2-f1) * scale; 
}
void    setViewFrameByCenterPos( UIView* view,CGPoint center)
{
	CGRect frame = view.frame;
	
	frame.origin.x = center.x - frame.size.width / 2;
	frame.origin.y = center.y - frame.size.height / 2;
	
	view.frame = frame;
}
BOOL	CGRectPointIntersect(CGRect rect,CGPoint p1)
{
	return BETWEEN(rect.origin.x,p1.x,rect.origin.x + rect.size.width)&&
		   BETWEEN(rect.origin.y,p1.y,rect.origin.y + rect.size.height);
}
CGPoint CGRectCenter(CGRect rect)
{
	return CGPointMake( CGRectGetMidX(rect), CGRectGetMidY(rect) );
}

NSMutableArray* ImagesWithFormatString( NSString* formatString,int minIndex,int maxIndex)
{
	NSMutableArray* array = [[NSMutableArray alloc] initWithCapacity: (maxIndex - minIndex)];
	for(int i = minIndex;i<=maxIndex;i++)
	{
		[array addObject: [UIImage imageNamed:[NSString stringWithFormat:formatString,i]]];
	}
	return array; 
}

int 	randRange(int min,int max) 
{
	return min + arc4random() % abs(max - min);
}
double  randFloat()
{
	return (double)arc4random() / ARC4RANDOM_MAX;
}



void 	UIViewSetX(UIView* view, int x)
{
	CGRect frame = view.frame;
	frame.origin.x = x;
	view.frame = frame;
}
void 	UIViewSetY(UIView* view, int y)
{
	CGRect frame = view.frame;
	frame.origin.y = y;
	view.frame = frame;
}
void 	UIViewSetOrigin(UIView* view, CGPoint origin)
{
	CGRect frame = view.frame;
	frame.origin = origin;
	view.frame = frame;
}
void 	UIViewSetWidth(UIView* view, int width)
{
	CGRect frame = view.frame;
	frame.size.width = width;
	view.frame = frame;
}
void 	UIViewSetHeight(UIView* view, int height)
{
	CGRect frame = view.frame;
	frame.size.height = height;
	view.frame = frame;
}
void 	UIViewSetSize(UIView* view, CGSize size)
{
	CGRect frame = view.frame;
	frame.size = size;
	view.frame = frame;
}

UIView* ReadNib( NSString* name,NSObject* owner)
{			
	NSArray* data = [[NSBundle mainBundle] loadNibNamed:name owner:owner options:nil];		
	return [data objectAtIndex:0];
}
void ShowAlertView(NSString* title,NSString* message,NSString* button1,NSString* button2)
{
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:title 
                                                       message:message 
                                                      delegate:NULL 
                                             cancelButtonTitle:button1 
                                             otherButtonTitles:button2, nil ];
    [alertView show];
}


/*
NSManagedObjectContext* getDefaultManagedObjectContext()
{
    return [AppDelegate getInstance].managedObjectContext;
}
*/

/*
NSDictionary* parseJSON(NSString* str)
{
    SBJsonParser* parser = [[SBJsonParser alloc]init];
    return [parser objectWithString:str];
}
 */



@implementation NSDictionary (StringMacro)

-(NSString*) stringForKey : (id) key
{
    return (NSString*)[self objectForKey:key];
    
}

@end


