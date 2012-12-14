//
//  ViewController.h
//  RollingPaper
//
//  Created by 이상현 on 12. 10. 27..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface RootViewController : UIViewController<FBFriendPickerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *loadingImageView;
@property (weak, nonatomic) IBOutlet UIImageView *paperPlaneView;
@property (weak, nonatomic) IBOutlet UIImageView *paperImageView;
@end
