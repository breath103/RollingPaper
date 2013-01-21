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

#import "UIFreeTransformGestureRecognizer.h"

#import "DockController.h"
//#import "CameraController.h"
#import "AlbumController.h"
#import "RecoderController.h"
#import "TypewriterController.h"
#import "PencilcaseController.h"



@class ImageContentView;

@interface PaperViewController : UIViewController <UIGestureRecognizerDelegate,
                                                   UIScrollViewDelegate,
                                                   DockControllerDelegate,
                                                   TypewriterControllerDelegate,
                                                //   CameraContorllerDelegate,
                                                   UIImagePickerControllerDelegate,
                                                   AlbumControllerDelegate,
                                                   RecoderViewControllerDelegate,
                                                   PencilcaseControllerDelegate,
                                                   FBFriendPickerDelegate>
@property (nonatomic,strong) UIView<RollingPaperContentViewProtocol>* transformTargetView;
@property (strong, nonatomic) FBFriendPickerViewController* friendPickerController;
@property (strong, nonatomic) RollingPaper* entity;
@property (nonatomic,weak) IBOutlet UIScrollView *contentsContainer;
@property (nonatomic,strong) UIView* contentsScrollContainer;
@property (nonatomic,strong) UIFreeTransformGestureRecognizer* freeTransformGestureRecognizer;
@property (nonatomic,strong) DockController* dockController;
@property (nonatomic,strong) UIViewController* currentEditingViewController;
@property (nonatomic,readwrite) BOOL isEditingMode;
/*
@property (nonatomic,strong) CameraController* cameraController;
@property (nonatomic,strong) AlbumController* albumController;
@property (nonatomic,strong) RecoderController* recoderController;
@property (nonatomic,strong) TypewriterController* typewriterController;
@property (nonatomic,strong) PencilcaseController* pencilcaseController;
*/
- (IBAction)onTouchRefresh:(id)sender;
-(ImageContentView*) onCreateImage : (UIImage *)image;
-(id) initWithEntity : (RollingPaper*) entity;
-(NSArray*) contentsViews;
@end
