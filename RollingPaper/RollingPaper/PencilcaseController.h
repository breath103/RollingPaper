//
//  PencilcaseController.h
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 19..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaintingView.h"
#import "ColorPalette.h"

@class PencilcaseController;

@protocol PencilcaseControllerDelegate <NSObject>
-(void) pencilcaseController : (PencilcaseController*) pencilcaseController
             didEndDrawImage : (UIImage*) image
                      inRect : (CGRect) rect;
-(void) pencilcaseControllerdidCancelDraw : (PencilcaseController *)pencilcaseController;
@end

@interface PencilcaseController : UIViewController<ColorPaletteDelegate>
@property (nonatomic,strong) id<PencilcaseControllerDelegate> delegate;
@property (nonatomic,strong) PaintingView* paintingView;
@property (atomic,readonly) BOOL isInLeftPanningMode;
@property (nonatomic,strong) UIButton* selectedButton;
@property (nonatomic,strong) NSMutableArray* toolButtons;
@property (weak, nonatomic) IBOutlet UIView *bottomDock;
@property (weak, nonatomic) IBOutlet UIButton *colorButton;
@property (weak, nonatomic) IBOutlet ColorPalette *colorPalette;

-(id) initWithDelegate : (id<PencilcaseControllerDelegate>) delegate;
- (IBAction)onTouchEndPaint:(id)sender;
- (IBAction)onTouchColor:(id)sender;
-(void) animateToLeftPanning;
- (IBAction)onTouchUndo:(id)sender;
- (IBAction)onTouchRedo:(id)sender;
- (IBAction)onTouchClear:(id)sender;
-(void) showBottomDock;
-(void) hideBottomDock;
@end
