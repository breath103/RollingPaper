//
//  RollingPaper.h
//  RollingPaper
//
//  Created by 이상현 on 12. 11. 20..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RollingPaper : NSManagedObject

@property (nonatomic, retain) NSNumber * creator_idx;
@property (nonatomic, retain) NSNumber * idx;
@property (nonatomic, retain) NSString * notice;
@property (nonatomic, retain) NSNumber * participants_count;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDecimalNumber * created_time;

@end
