//
//  SoundContent.h
//  RollingPaper
//
//  Created by 이상현 on 12. 11. 24..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SoundContent : NSManagedObject

@property (nonatomic, retain) NSNumber * idx;
@property (nonatomic, retain) NSNumber * paper_idx;
@property (nonatomic, retain) NSNumber * user_idx;
@property (nonatomic, retain) NSNumber * x;
@property (nonatomic, retain) NSNumber * y;
@property (nonatomic, retain) NSString * sound;

@end
