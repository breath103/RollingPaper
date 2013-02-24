//
//  User.m
//  RollingPaper
//
//  Created by 이상현 on 13. 2. 3..
//  Copyright (c) 2013년 reserved.
//

#import "User.h"

@implementation User
-(id) init {
    self = [super init];
    if(self){
        self.birthday             = [NSNull null];
        self.email                = [NSNull null];
        self.facebook_accesstoken = [NSNull null];
        self.facebook_id          = [NSNull null];
        self.idx                  = [NSNull null];
        self.name                 = [NSNull null];
        self.picture              = [NSNull null];
        self.phone                = [NSNull null];
    }
    return self;
}
-(id) initWithDict : (NSDictionary*) dict{
    self = [self init];
    if(self){
        self.birthday             = [dict objectForKey:@"birthday"];
        self.email                = [dict objectForKey:@"email"];
        self.facebook_accesstoken = [dict objectForKey:@"facebook_accesstoken"];
        self.facebook_id          = [dict objectForKey:@"facebook_id"];
        self.idx                  = [dict objectForKey:@"idx"];
        self.name                 = [dict objectForKey:@"name"];
        self.picture              = [dict objectForKey:@"picture"];
        self.phone                = [dict objectForKey:@"phone"];
    }
    return self;
}
-(NSDictionary*) toDictionary{
    return @{@"idx": self.idx,
             @"name" : self.name,
             @"email" : self.email,
             @"picture" : self.picture,
             @"phone" : self.phone,
             @"birthday" : self.birthday,
             @"facebook_id" : self.facebook_id,
             @"facebook_accesstoken" : self.facebook_accesstoken};
}
+(NSArray*) userWithDictArray : (NSArray*) dictArray{
    NSMutableArray* users = [[NSMutableArray alloc]initWithCapacity:dictArray.count];
    for(NSDictionary* userDict in dictArray){
        [users addObject:[[User alloc] initWithDict:userDict]];
    }
    return users;
}

-(void) getPicture : (void(^)(UIImage* image)) callback{
}
@end
