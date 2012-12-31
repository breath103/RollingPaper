//
//  PhoneAuthViewController.h
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 22..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhoneAuthViewController : UIViewController<UIAlertViewDelegate>
- (IBAction)onTouchDontUsePhone:(id)sender;
- (IBAction)onTouchStartAuth:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *phoneInput;

@end
