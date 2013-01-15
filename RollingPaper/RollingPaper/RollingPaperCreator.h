//
//  RollingPaperCreatorController.h
//  RollingPaper
//
//  Created by 이상현 on 12. 11. 17..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "FBFriendSearchPickerController.h"




@interface RollingPaperCreator : UIViewController<FBFriendPickerDelegate,UISearchBarDelegate>

@property (nonatomic,strong) FBFriendSearchPickerController* friendPickerController;
@property (weak, nonatomic) IBOutlet UIView* contentContainer;
@property (weak, nonatomic) IBOutlet UITextField *titleText;
@property (weak, nonatomic) IBOutlet UITextField *emailInput;
@property (weak, nonatomic) IBOutlet UITextField *noticeInput;
@property (weak, nonatomic) IBOutlet UITextField *receiverName;
@property (weak, nonatomic) IBOutlet UITextField *receiveDate;
@property (weak, nonatomic) IBOutlet UITextField *receiveTime;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;
@property (nonatomic,weak) IBOutlet UIScrollView* scrollView;
@property (nonatomic,strong) NSString* receiverFacebookID;

- (IBAction)onTouchSend:(id)sender;
- (IBAction)onTouchPickFriend:(id)sender;
- (IBAction)onHideKeyboard:(id)sender;
- (IBAction)onPickDate:(UIDatePicker *)sender;
- (IBAction)onPickTime:(UIDatePicker *)sender;
- (IBAction)onTouchReceiveDate:(id)sender;

@end
