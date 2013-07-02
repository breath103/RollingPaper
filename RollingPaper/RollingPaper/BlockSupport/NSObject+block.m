#import "NSObject+block.h"

@implementation NSObject(PerformSelectorBlockSupport)
-(void) _performBlock : (NSObjectProgressBlock) block
{
    block();
    
}
-(void) _performBlockWithArgument : (NSObjectProgressBlock) block{
    block();
    
}
-(void) performBlockInBackground : (NSObjectProgressBlock) block
{
    [self performSelectorInBackground : @selector(_performBlock:) withObject:block];
}
-(void) performBlockInMainThread : (NSObjectProgressBlock) block
                   waitUntilDone : (BOOL) waitUntilDone
{
    [self performSelectorOnMainThread : @selector(_performBlock:)
                           withObject : block
                        waitUntilDone : waitUntilDone];
}
-(void) performBlock : (NSObjectProgressBlock)block
          afterDelay : (NSTimeInterval)delay{
    [self performSelector:@selector(_performBlockWithArgument:)
               withObject:block
               afterDelay:delay];
}
@end
