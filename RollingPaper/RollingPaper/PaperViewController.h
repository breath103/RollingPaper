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

#import "UIFreeTransformGestureRecognizer.h"

#import "DockController.h"
#import "CameraController.h"
#import "AlbumController.h"
#import "RecoderController.h"
#import "TypewriterController.h"
#import "PencilcaseController.h"

@interface PaperViewController : UIViewController <UIGestureRecognizerDelegate,
                                                   DockControllerDelegate,
                                                   TypewriterControllerDelegate,
                                                   CameraContorllerDelegate,
                                                   AlbumControllerDelegate,
                                                   RecoderViewControllerDelegate,
                                                   FBFriendPickerDelegate>
@property (nonatomic,strong) UIView<RollingPaperContentViewProtocol>* transformTargetView;
@property (weak , nonatomic) IBOutlet PaintingView* paintingView;
@property (strong, nonatomic) FBFriendPickerViewController* friendPickerController;
@property (strong, nonatomic) NSMutableArray* contentsViews;
@property (strong, nonatomic) RollingPaper* entity;

@property (weak, nonatomic) IBOutlet UIScrollView *contentsContainer;

@property (nonatomic,strong) UIFreeTransformGestureRecognizer* freeTransformGestureRecognizer;
@property (nonatomic,strong) DockController* dockController;
@property (nonatomic,strong) CameraController* cameraController;
@property (nonatomic,strong) AlbumController* albumController;
@property (nonatomic,strong) RecoderController* recoderController;
@property (nonatomic,strong) TypewriterController* typewriterController;

-(void) onCreateImage : (UIImage *)image;
-(id) initWithEntity : (RollingPaper*) entity;

@end
