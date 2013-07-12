//
//  NSRandomSupport.m
//  RollingPaper
//
//  Created by 이상현 on 13. 1. 15..
//  Copyright (c) 2013년 상현 이. All rights reserved.
//

#import "NSRandomSupport.h"

@implementation NSArray(RandomSupport)
-(id) randomObject{
    return [self objectAtIndex: (arc4random() % self.count) ];
}
@end