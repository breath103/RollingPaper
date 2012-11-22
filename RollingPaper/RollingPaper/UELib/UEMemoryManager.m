//
//  UEMemoryManager.m
//  Madeleine
//
//  Created by 상현 이 on 12. 4. 1..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "UEMemoryManager.h"

@implementation UEMemoryReleasableObject
-(id) init
{
    self = [super init];
    if(self)
    {
        [[UEMemoryManager sharedInstance] addReleasableObject:self];
    }
    return self;
}
-(BOOL) isReleasble
{
    return FALSE;
}
-(void) releaseMemory
{
    return;
}
@end


@implementation UEMemoryManager
+ (UEMemoryManager*)sharedInstance
{
    static dispatch_once_t pred;
    static UEMemoryManager *sharedInstance = nil;
    dispatch_once(&pred, ^{
        sharedInstance = [[UEMemoryManager alloc] init];
    });
    return sharedInstance;
}
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        releasableObjects = [[NSMutableOrderedSet alloc]init];
    }
    return self;
}

-(void) addReleasableObject : (UEMemoryReleasableObject*) releasableObject
{
    [releasableObjects addObject:releasableObjects];
}
-(void) releaseMemory  //메모리 해제
{
    for(UEMemoryReleasableObject* object in releasableObjects)
    {
        if([object isReleasble])
            [object releaseMemory];
    }
}
@end





