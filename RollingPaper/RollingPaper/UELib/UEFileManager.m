//
//  UEFileManager.m
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 15..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "UEFileManager.h"

@implementation UEFileManager
+(BOOL) writeData : (NSData*) data
      ToLocalFile : (NSString*) fileName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths
                                    objectAtIndex:0];
    NSString* filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,fileName];
   
    return [data writeToFile:filePath
                  atomically:NO];
}

+(NSData*) readDataFromLocalFile : (NSString*) file{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,file];
    NSLog(@"%@에서 리소스 탐색",filePath);
    return [NSData dataWithContentsOfFile:filePath];
}
@end
