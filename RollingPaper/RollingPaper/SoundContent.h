//
//  SoundContent.h
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 20..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Content.h"


@interface SoundContent : Content

@property (nonatomic, retain) NSNumber * idx;
@property (nonatomic, retain) NSNumber * paper_idx;
@property (nonatomic, retain) NSString * sound;
@property (nonatomic, retain) NSNumber * user_idx;

@end
