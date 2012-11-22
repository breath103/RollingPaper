//
//  RollingPaperCreatorController.h
//  RollingPaper
//
//  Created by 이상현 on 12. 11. 17..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface RollingPaperCreator : UIViewController<FBFriendPickerDelegate>

@property (nonatomic,strong) FBFriendPickerViewController* friendPickerController;
@property (weak, nonatomic) IBOutlet UITextField *titleText;
@property (weak, nonatomic) IBOutlet UITextField *emailInput;
@property (weak, nonatomic) IBOutlet UITextField *noticeInput;
@property (weak, nonatomic) IBOutlet UILabel *fbIdLabel;
@property (weak, nonatomic) IBOutlet UITextField *receiverName;
@property (weak, nonatomic) IBOutlet UITextField *receiveTime;

- (IBAction)onTouchSend:(id)sender;
- (IBAction)onTouchPickFriend:(id)sender;
- (IBAction)onHideKeyboard:(id)sender;

@end
