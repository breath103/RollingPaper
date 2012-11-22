//
//  NSObject+RollingPaperContentView.h
//  RollingPaper
//
//  Created by 이상현 on 12. 11. 21..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RollingPaperContentView <NSObject>
@property(atomic) bool isNeedToSyncWithServer;
@end
