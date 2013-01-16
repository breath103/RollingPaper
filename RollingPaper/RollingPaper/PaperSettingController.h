//
//  PaperSettingController.h
//  RollingPaper
//
//  Created by 이상현 on 13. 1. 15..
//  Copyright (c) 2013년 상현 이. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RollingPaper.h"

@interface PaperSettingController : UIViewController
@property (nonatomic,strong) RollingPaper* entity;
@property (weak, nonatomic) IBOutlet UITextField *titleText;
@property (weak, nonatomic) IBOutlet UITextField *receiveTime;
-(id) initWithPaper : (RollingPaper*) entity;
@end
