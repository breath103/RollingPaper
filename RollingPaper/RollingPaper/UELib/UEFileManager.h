//
//  UEFileManager.h
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 15..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UEFileManager : NSObject
+(BOOL) writeData : (NSData*) data
      ToLocalFile : (NSString*) fileName;
+(NSData*) readDataFromLocalFile : (NSString*) file;
@end
