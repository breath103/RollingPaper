//
//  UEInfoList.h
//  Madeleine
//
//  Created by 상현 이 on 12. 4. 7..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UEInfoList : NSObject
+(id) getObjectForKey : (id) key;
+(void) setObjectForKey : (id) key object : (id) object;

//NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
@end
