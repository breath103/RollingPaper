//
//  UserInfo.m
//  Madeleine
//
//  Created by 상현 이 on 12. 4. 7..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "UserInfo.h"


//NSDictionary* userDict;

@implementation UserInfo
+(void) setUserInfo : (NSDictionary*) dict{
    [[NSUserDefaults standardUserDefaults] setObject:dict
                                              forKey:@"userinfo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+(NSDictionary*) getUserInfo {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"userinfo"];
}
+(NSNumber*) getUserIdx{
    return [[UserInfo getUserInfo] objectForKey:@"idx"];
}
+(UIImage*) getImageFromPictrueURL{
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[UserInfo getUserInfo] objectForKey:@"picture"]]]];
}
@end
