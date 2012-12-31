//
//  UserInfo.h
//  Madeleine
//
//  Created by 상현 이 on 12. 4. 7..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserInfo : NSObject
+(void) setUserInfo : (NSDictionary*) dict;
+(NSDictionary*) getUserInfo;
+(NSNumber*) getUserIdx;

/*
@property (nonatomic,strong) NSString* name;
@property (nonatomic,strong) NSString* email;
@property (nonatomic,strong) NSString* password;
@property (nonatomic,strong) NSString* userid;

+(UserInfo*) getUserInfoFromUserDefaults;

-(void) save;
*/
@end
