#import <UIKit/UIKit.h>

@interface UIView (AnimationMacro)
-(void) hideToTransparent;
-(void) showFromTransparent;
-(void) fadeIn : (float) duration;
-(void) fadeOut : (float) duration;
-(BOOL) fadeToggle : (float) duration;

-(void) disableScrollsToTopPropertyOnAllSubviews;
-(void) disableScrollsToTopPropertyOnAllSubviewsOf:(UIView *)view;
@end
