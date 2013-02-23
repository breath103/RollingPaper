
#import <UIKit/UIKit.h>


typedef void (^AlertViewCallback)(UIAlertView* alertView,int clickedButtonIndex);
@class UIAlertViewBlockDelegate;

@interface UIAlertViewBlock : UIAlertView{
    UIAlertViewBlockDelegate* blockDelegate;
}
- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
      blockDelegate:(AlertViewCallback) block
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;
@end


@interface UIAlertViewBlockDelegate : NSObject<UIAlertViewDelegate>{
    AlertViewCallback block;
}
-(id) initWithBlock : (AlertViewCallback) block;
@end
