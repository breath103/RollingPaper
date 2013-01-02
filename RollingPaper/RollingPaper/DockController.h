//
//  DockController.h
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 18..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum DockMenuType {
    DockMenuTypeCamera = 0,
    DockMenuTypeAlbum,
    DockMenuTypeKeyboard,
    DockMenuTypePencilcase,
    DockMenuTypeMicrophone,
} DockMenuType;

@class DockController;

@protocol DockControllerDelegate <NSObject>
-(void) dockController : (DockController*) dockController
              pickMenu : (DockMenuType) menuType
              inButton : (UIButton*) button;
@end

@interface DockController : UIViewController
@property (atomic,readonly) BOOL isDockPoped;
@property (nonatomic,weak) id<DockControllerDelegate> delegate;
@property (nonatomic,strong) UIPanGestureRecognizer* panGestureRecognizer;
@property (nonatomic,strong) IBOutlet UIView* dockView;
-(id) initWithDelegate : (id<DockControllerDelegate>) delegate;
-(void) hide;
-(void) show;
-(void) onDockGesture : (UIPanGestureRecognizer*) gestureRecognizer;
- (IBAction)onTouchCamera:(id)sender;
- (IBAction)onTouchAlbum :(id)sender;
- (IBAction)onTouchKeyboard:(id)sender;
- (IBAction)onTouchMicrophone:(id)sender;
- (IBAction)onTouchPencilcase:(id)sender;
- (IBAction)onTouchShowToggleButton:(id)sender;

@end
