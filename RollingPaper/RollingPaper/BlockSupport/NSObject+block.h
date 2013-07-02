#import <Foundation/Foundation.h>

typedef void (^NSObjectProgressBlock)();
typedef void (^NSObjectArgumentBlock)(id arg);

@interface NSObject(PerformSelectorBlockSupport)

-(void) performBlockInBackground:(NSObjectProgressBlock) block;
-(void) performBlockInMainThread:(NSObjectProgressBlock) block
                   waitUntilDone:(BOOL) waitUntilDone;
-(void) performBlock:(NSObjectProgressBlock) block
          afterDelay:(NSTimeInterval)delay;
@end
