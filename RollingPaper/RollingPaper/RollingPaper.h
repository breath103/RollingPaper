//
//  RollingPaper.h
//  RollingPaper
//
//  Created by 이상현 on 13. 1. 15..
//  Copyright (c) 2013년 상현 이. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Content;

@interface RollingPaper : NSManagedObject

@property (nonatomic, retain) NSString* created_time;
@property (nonatomic, retain) NSNumber* creator_idx;
@property (nonatomic, retain) NSNumber* height;
@property (nonatomic, retain) NSNumber* idx;
@property (nonatomic, retain) NSString* is_sended;
@property (nonatomic, retain) NSString* notice;
@property (nonatomic, retain) NSNumber* participants_count;
@property (nonatomic, retain) NSString* receive_time;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSDate* update_time;
@property (nonatomic, retain) NSNumber* width;
@property (nonatomic, retain) NSNumber* is_new;
@property (nonatomic, retain) NSSet* contents;
@end

@interface RollingPaper (CoreDataGeneratedAccessors)

- (void)addContentsObject:(Content *)value;
- (void)removeContentsObject:(Content *)value;
- (void)addContents:(NSSet *)values;
- (void)removeContents:(NSSet *)values;

@end
