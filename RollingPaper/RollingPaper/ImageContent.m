//
//  ImageContent.m
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 20..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "ImageContent.h"
#import "UECoreData.h"

@implementation ImageContent

@dynamic idx;
@dynamic image;
@dynamic paper_idx;
@dynamic user_idx;


+(ImageContent*) contentWithDictionary : (NSDictionary*) dict{
    ImageContent* imageEntity = (ImageContent*)[[UECoreData sharedInstance]insertNewObject:@"ImageContent" initWith:dict];
    return imageEntity;
}
+(NSArray*) contentsWithDictionaryArray : (NSArray*) array{
    
    NSMutableArray* entitys = [NSMutableArray arrayWithCapacity:array.count];
    for(NSDictionary*p in array){
        ImageContent* imageEntity = (ImageContent*)[[UECoreData sharedInstance]insertNewObject:@"ImageContent" initWith:p];
        [entitys addObject:imageEntity];
    }
    return entitys;
}

@end
