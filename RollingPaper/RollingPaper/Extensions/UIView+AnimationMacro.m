#import "UIView+AnimationMacro.h"

@implementation UIView (AnimationMacro)
-(void) hideToTransparent
{
    self.alpha = 0.0f;
    self.hidden = YES;
}
-(void) showFromTransparent
{
    self.alpha = 1.0f;
    self.hidden = NO;
}
-(void) fadeIn : (float) duration
{
    self.hidden = NO;
    [UIView animateWithDuration:duration animations:^{
        self.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
    }];
}
-(void) fadeOut : (float) duration
{
    [UIView animateWithDuration:duration animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}
//in이면 1 out이면 0
-(BOOL) fadeToggle : (float) duration
{
    if(self.alpha > 0.0f){
        [self fadeOut:duration];
        return 0;
    }
    else{
        [self fadeIn:duration];
        return 1;
    }
}
@end
