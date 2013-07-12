
#import <UIKit/UIKit.h>

typedef void (^UITapGestureRecognizerBlockCallback)(UITapGestureRecognizer* gestureRecognizer,UIView* view);

@interface UITapGestureRecognizer (BlockSupport)

-(id) initWithCallback : (UITapGestureRecognizerBlockCallback) block;

@end
