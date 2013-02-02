//
//  User.m
//  RollingPaper
//
//  Created by 이상현 on 13. 2. 3..
//  Copyright (c) 2013년 reserved.
//

#import "User.h"

@implementation User
-(id) initWithDict : (NSDictionary*) dict{
    self = [self init];
    if(self){
        self.birthday = [dict objectForKey:@"birthday"];
        self.email    = [dict objectForKey:@"email"];
        self.facebook_accesstoken = [dict objectForKey:@"facebook_accesstoken"];
        self.facebook_id = [dict objectForKey:@"facebook_id"];
        self.idx = [dict objectForKey:@"idx"];
        self.name = [dict objectForKey:@"name"];
        self.picture = [dict objectForKey:@"picture"];
    }
    return self;
}
@end
