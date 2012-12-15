//
//  PaperViewController.h
//  RollingPaper
//
//  Created by 이상현 on 12. 11. 18..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

#import "RollingPaper.h"
#import "RollingPaperContentViewProtocol.h"
#import "PaintingView.h"

#import "RecoderViewController.h"
#import "CameraViewController.h"
#import "UIFreeTransformGestureRecognizer.h"

@interface PaperViewController : UIViewController <UIImagePickerControllerDelegate,
                                                   RecoderViewControllerDelegate,
                                                   CameraViewControllerDelegate,
                                                   FBFriendPickerDelegate>{
    UIPanGestureRecognizer* pan;
}
@property (nonatomic,strong) UIView<RollingPaperContentViewProtocol>* transformTargetView;
@property (weak, nonatomic) IBOutlet UIButton *soundButton;
@property (weak , nonatomic) IBOutlet PaintingView* paintingView;
@property (strong, nonatomic) FBFriendPickerViewController* friendPickerController;
@property (strong, nonatomic) NSMutableArray* contentsViews;
@property (strong, nonatomic) RollingPaper* entity;
@property (weak, nonatomic) IBOutlet UIView *menuDock;
@property (weak, nonatomic) IBOutlet UIScrollView *contentsContainer;

@property (nonatomic,strong) UIFreeTransformGestureRecognizer* freeTransformGestureRecognizer;

@property (nonatomic,strong) CameraViewController* cameraViewController;
@property (nonatomic,strong) RecoderViewController* recoderViewController;

- (IBAction)onTouchSound:(id)sender;
- (IBAction)onTouchBrush:(id)sender;
- (IBAction)onAddImage:(id)sender;
- (IBAction)onTouchInvite:(id)sender;
-(id) initWithEntity : (RollingPaper*) entity;

@end
