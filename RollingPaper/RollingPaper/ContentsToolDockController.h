//
//  ContentsToolDockController.h
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 16..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ContentsToolDockController;

@protocol  ContentsToolDockControllerDelegate<NSObject>

@end

@interface ContentsToolDockController : UIViewController
    @property (nonatomic,weak) id<ContentsToolDockControllerDelegate> delegate;
@end
