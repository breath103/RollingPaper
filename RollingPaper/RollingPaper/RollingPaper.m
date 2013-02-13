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

@implementation RollingPaper(NetworkingHelper)
- (NSDictionary*) dictionaryForUpdateRequest{
    NSDictionary *params = @{
        @"title" : self.title,
        @"width" : self.width,
        @"height" : self.height,
        @"receive_time" : self.receive_time,
        @"notice" : self.notice,
        @"receiver_fb_id" : self.receiver_fb_id,
        @"receiver_name" : self.receiver_name,
        @"receive_tel" : self.receive_tel,
        @"background" : self.background,
        @"target_email" : self.target_email
    };
    return params;
}
@end


