//
//  RollingPaper.m
//  RollingPaper
//
//  Created by 이상현 on 13. 1. 17..
//  Copyright (c) 2013년 상현 이. All rights reserved.
//

#import "RollingPaper.h"
#import "Content.h"


@implementation RollingPaper

@dynamic created_time;
@dynamic creator_idx;
@dynamic height;
@dynamic idx;
@dynamic is_new;
@dynamic is_sended;
@dynamic notice;
@dynamic participants_count;
@dynamic receive_time;
@dynamic title;
@dynamic update_time;
@dynamic width;
@dynamic background;
@dynamic contents;
@dynamic receiver_name;
@dynamic target_email;
@dynamic receive_tel;
@dynamic receiver_fb_id;
+(NSMutableArray*) papersWithDictionaryArray : (NSArray*) dictionaryArray{
    return NULL;
}
@end

#define NullToNSNull(x) ( (x)?(x):[NSNull null] )

@implementation RollingPaper(NetworkingHelper)
- (NSDictionary*) dictionaryForUpdateRequest{
    NSDictionary *params = @{
        @"title"    : NullToNSNull(self.title),
        @"width"    : NullToNSNull(self.width),
        @"height"   : NullToNSNull(self.height),
        @"receive_time" : NullToNSNull(self.receive_time),
        @"notice"   : NullToNSNull(self.notice),
        @"receiver_fb_id" : NullToNSNull(self.receiver_fb_id),
        @"receiver_name"  : NullToNSNull(self.receiver_name),
        @"receive_tel"    : NullToNSNull(self.receive_tel),
        @"background"     : NullToNSNull(self.background),
        @"target_email"   : NullToNSNull(self.target_email)
    };
    return params;
}
@end


