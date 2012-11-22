//
//  UEDataStructure.m
//  Madeleine
//
//  Created by 상현 이 on 12. 4. 18..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "UEDataStructure.h"


@implementation NSMutableArray (Queue_method)
-(void) push : (id) object
{
    [self addObject:object];
}
-(id) pop : (BOOL) bRemoveObject
{
    id object =[self objectAtIndex:0];
    if(bRemoveObject)
        [self removeObjectAtIndex:0];
    return object;
}

-(id) getFromBack : (BOOL) bRemoveObject
{
    int lastIndex = self.count - 1;
    id object = [self objectAtIndex:lastIndex];
    if(bRemoveObject)
        [self objectAtIndex:lastIndex];
    return object;
}
@end