//
//  Content.h
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 20..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RollingPaper;

@interface Content : NSManagedObject

@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSNumber * rotation;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSNumber * x;
@property (nonatomic, retain) NSNumber * y;
@property (nonatomic, retain) RollingPaper *paper;

@end
