

#import "UIAlertViewBlockDelegate.h"
@implementation UIAlertViewBlock
- (id)initWithTitle:(NSString *)title
            message:(NSString *)message
      blockDelegate:(AlertViewCallback) block
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSString *)otherButtonTitles, ...{
    self = [self initWithTitle:title
                       message:message
                      delegate:NULL
             cancelButtonTitle:cancelButtonTitle
             otherButtonTitles:otherButtonTitles, nil];
    if(self){
        blockDelegate = [[UIAlertViewBlockDelegate alloc]initWithBlock:block];
        self.delegate = blockDelegate;
    }
    return self;
}
@end


@implementation UIAlertViewBlockDelegate
-(id) initWithBlock : (AlertViewCallback) aBlock{
    block = aBlock;
    if(self){
        
    }
    return self;
}
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"%@",block);
    
    block(alertView,buttonIndex);
}
@end
