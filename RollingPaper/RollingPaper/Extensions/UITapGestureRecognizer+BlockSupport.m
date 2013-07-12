#import "UITapGestureRecognizer+BlockSupport.h"



@interface UITapGestureRecognizerDelegateContainer : NSObject{
    NSMutableDictionary* delegateContainer;
}
- (void)registerDelegate : (UITapGestureRecognizerBlockCallback) delegate
                     key : (id) key;
//- (UIAlertViewBlockDelegate*) delegateForView : (UIAlertView*) view;
+ (id)sharedInstance ;
- (id)init;
@end


@implementation UITapGestureRecognizerDelegateContainer
- (void)registerDelegate : (UITapGestureRecognizerBlockCallback) delegate
                     key : (id) key{
    [delegateContainer setObject:delegate forKey:@((int)key)];
}
- (UITapGestureRecognizerBlockCallback) delegateForkey : (id) key;{
    return (UITapGestureRecognizerBlockCallback)[delegateContainer objectForKey:@((int)key)];
}
- (void)unregisterDelegateInkey : (id) key;{
    [delegateContainer removeObjectForKey:@((int)key)];
}
+ (id)sharedInstance {
    static UITapGestureRecognizerDelegateContainer *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[UITapGestureRecognizerDelegateContainer alloc] init];
    });
    return instance;
}
- (id)init{
    self = [super init];
    if(self){
        delegateContainer = [NSMutableDictionary new];
    }
    return self;
}
@end






@implementation UITapGestureRecognizer (BlockSupport)
-(id) initWithCallback : (UITapGestureRecognizerBlockCallback) block{
    self = [self initWithTarget:self action:@selector(onTapGesture)];
    if(self){
        [[UITapGestureRecognizerDelegateContainer sharedInstance]registerDelegate:block
                                                                             key:self];
    }
    return self;
}
-(void) onTapGesture{
    [[UITapGestureRecognizerDelegateContainer sharedInstance]delegateForkey:self](self,self.view);
}
@end
