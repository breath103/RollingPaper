//
//  ViewController.h
//  RollingPaper
//
//  Created by 이상현 on 12. 10. 27..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface RootViewController : UIViewController<FBFriendPickerDelegate>{
    FBFriendPickerViewController* friendPickerController ;
}
- (IBAction)onTouchLoginWithFacebook:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *loadingImageView;
@property (weak, nonatomic) IBOutlet UIButton *facebookLoginButton;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *paperPlaneView;
@property (weak, nonatomic) IBOutlet UIImageView *paperImageView;
- (IBAction)onTouchList:(id)sender;
- (IBAction)onTouchCreate:(id)sender;


@end
