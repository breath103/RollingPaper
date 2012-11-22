//
//  UEInfoList.m
//  Madeleine
//
//  Created by 상현 이 on 12. 4. 7..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "UEInfoList.h"

@implementation UEInfoList
+(id) getObjectForKey : (id) key
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:key];   
}
+(void) setObjectForKey : (id) key object : (id) object
{
    
}

@end
