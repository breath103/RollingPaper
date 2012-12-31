//
//  PaperSettingViewController.h
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 25..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RollingPaper.h"

@interface PaperSettingViewController : UIViewController
@property (nonatomic,strong) RollingPaper* entity;
-(id) initWithEntity : (RollingPaper*) entity;
@end
