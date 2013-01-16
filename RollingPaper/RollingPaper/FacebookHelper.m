//
//  FacebookHelper.m
//  RollingPaper
//
//  Created by 이상현 on 13. 1. 7..
//  Copyright (c) 2013년 상현 이. All rights reserved.
//

#import "FacebookHelper.h"

@implementation FacebookHelper
-(NSDate*) facebookDateToNSDate : (NSString*) str{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    return [dateFormatter dateFromString:str];
}
@end
