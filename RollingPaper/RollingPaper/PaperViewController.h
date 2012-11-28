//
//  PaperViewController.h
//  RollingPaper
//
//  Created by 이상현 on 12. 11. 18..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoPickingView/PhotoPickerController.h"
#import "PhotoPickingView/AlbumPickerController.h"
#import "RollingPaper.h"
#import "RollingPaperContentViewProtocol.h"
#import <FacebookSDK/FacebookSDK.h>
#import "PaintingView.h"
#import "UESoundRecoder.h"

@interface PaperViewController : UIViewController<AlbumPickerControllerDelegate,
                                                  PhotoPickerControllerDelegate,
                                                  FBFriendPickerDelegate>
{
    UIView<RollingPaperContentViewProtocol>* transformTargetView;
    CGPoint lastPoint;
}
@property (nonatomic,strong) UESoundRecoder* recoder;
@property (weak, nonatomic) IBOutlet UIButton *soundButton;
@property (weak , nonatomic) IBOutlet PaintingView* paintingView;
@property (strong, nonatomic) FBFriendPickerViewController* friendPickerController;
@property (strong, nonatomic) NSMutableArray* contentsViews;
@property (strong, nonatomic) RollingPaper* entity;
@property (strong, nonatomic) AlbumPickerController* albumPickerController;
@property (strong, nonatomic) PhotoPickerController* photoPickerController;
- (IBAction)onTouchSound:(id)sender;
- (IBAction)onTouchBrush:(id)sender;
- (IBAction)onAddImage:(id)sender;
- (IBAction)onTouchInvite:(id)sender;
-(id) initWithEntity : (RollingPaper*) entity;
@end
