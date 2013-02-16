//
//  UserSettingViewController.h
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 22..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserSettingViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UITextView *feedbackInput;
- (IBAction)onTouchShowNotice:(id)sender;
- (IBAction)onTouchFeedbackButton:(id)sender;

@end
