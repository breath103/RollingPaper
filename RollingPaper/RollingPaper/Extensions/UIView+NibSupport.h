#import <UIKit/UIKit.h>

@interface UIView (NibSupport)
-(id) initWithNib;
-(id) initWithNib : (NSString*) nibName;
+(UIView*) viewWithNib : (NSString*) nibName;
@end
