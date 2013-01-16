//
//  TextContent.h
//  RollingPaper
//
//  Created by 이상현 on 13. 1. 15..
//  Copyright (c) 2013년 상현 이. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Content.h"


@interface TextContent : Content

@property (nonatomic, retain) NSNumber * color;
@property (nonatomic, retain) NSString * font;
@property (nonatomic, retain) NSNumber * idx;
@property (nonatomic, retain) NSNumber * paper_idx;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * user_idx;

@end
