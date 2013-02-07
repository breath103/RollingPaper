//
//  SoundContent.m
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 20..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "SoundContent.h"
#import "UECoreData.h"

@implementation SoundContent

@dynamic idx;
@dynamic paper_idx;
@dynamic sound;
@dynamic user_idx;

+(SoundContent*) contentWithDictionary : (NSDictionary*) dict{
    SoundContent* soundEntity = (SoundContent*)[[UECoreData sharedInstance]insertNewObject:@"SoundContent" initWith:dict];
    return soundEntity;
}
+(NSArray*) contentsWithDictionaryArray : (NSArray*) array{
    NSMutableArray* entitys = [NSMutableArray arrayWithCapacity:array.count];
    for(NSDictionary*p in array){
         SoundContent* soundEntity = (SoundContent*)[[UECoreData sharedInstance]insertNewObject:@"SoundContent" initWith:p];
        [entitys addObject:soundEntity];
    }
    return entitys;
}

@end
