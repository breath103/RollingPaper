//
//  ImageContent.h
//  RollingPaper
//
//  Created by 이상현 on 12. 11. 21..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ImageContent : NSManagedObject

@property (nonatomic, retain) NSNumber * idx;
@property (nonatomic, retain) NSNumber * paper_idx;
@property (nonatomic, retain) NSNumber * user_idx;
@property (nonatomic, retain) NSNumber * x;
@property (nonatomic, retain) NSNumber * y;
@property (nonatomic, retain) NSNumber * rotation;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSNumber * height;

@end
