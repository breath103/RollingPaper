//
//  NSObject+block.h
//  MyJournal
//
//  Created by 이상현 on 12. 9. 8..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^NSObjectProgressBlock)();
typedef void (^NSObjectArgumentBlock)(id arg);

@interface NSObject(PerformSelectorBlockSupport)

-(void) performBlockInBackground : (NSObjectProgressBlock) block;
-(void) performBlockInMainThread : (NSObjectProgressBlock) block
                   waitUntilDone : (BOOL) waitUntilDone;
-(void) performBlock : (NSObjectProgressBlock) block
          afterDelay : (NSTimeInterval)delay;



@end
