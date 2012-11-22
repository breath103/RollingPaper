//
//  UserInfo.m
//  Madeleine
//
//  Created by 상현 이 on 12. 4. 7..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "UserInfo.h"


NSDictionary* userDict;

@implementation UserInfo
+(void) setUserInfo : (NSDictionary*) dict{
    userDict = dict;
}
+(NSDictionary*) getUserInfo {
    return userDict;
}
+(NSString*) getUserIdx{
    return [[UserInfo getUserInfo] objectForKey:@"idx"];
}

/*
@synthesize name;
@synthesize email;
@synthesize userid;
@synthesize password;

+(UserInfo*) getUserInfoFromUserDefaults
{
    NSString* name     = [[NSUserDefaults standardUserDefaults] objectForKey:@"MadeleineUserName"];
    NSString* email    = [[NSUserDefaults standardUserDefaults] objectForKey:@"MadeleineUserEmail"];
    NSString* userid   = [[NSUserDefaults standardUserDefaults] objectForKey:@"MadeleineUserid"];
    NSString* password = [[NSUserDefaults standardUserDefaults] objectForKey:@"MadeleineUserPassword"];

    UserInfo* userInfo = NULL;
    
    if(email && userid && password)
    {
        userInfo = [[UserInfo alloc]init];
        userInfo.name     = name;
        userInfo.email    = email;
        userInfo.userid   = userid;
        userInfo.password = password;
    }
    return userInfo;
}

-(NSString*) description
{
    return [NSString stringWithFormat:@"%@ %@ %@ %@",name,email,userid,password];
}
-(void) save
{
    [[NSUserDefaults standardUserDefaults] setValue:name                 forKey:@"MadeleineUserName"];
    [[NSUserDefaults standardUserDefaults] setValue:email                forKey:@"MadeleineUserEmail"];
    [[NSUserDefaults standardUserDefaults] setValue:userid               forKey:@"MadeleineUserid"];
    [[NSUserDefaults standardUserDefaults] setValue:password             forKey:@"MadeleineUserPassword"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
*/
@end
