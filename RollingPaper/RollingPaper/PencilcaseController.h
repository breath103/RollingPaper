//
//  PencilcaseController.h
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 19..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum TOOL_TYPE{
    PENCIL,
    NAMEPEN,
    LIGHTPEN,
    MAGICPEN,
    BALLPEN,
    TOOL_COUNT
} TOOL_TYPE;

@class PencilcaseController;

@protocol PencilcaseControllerDelegate <NSObject>
-(void) pencilcaseController : (PencilcaseController*) pencilcaseController
             didEndDrawImage : (UIImage*) image;
@end

@interface PencilcaseController : UIViewController
@property (nonatomic,strong) id<PencilcaseControllerDelegate> delegate;
@property (atomic,readonly) BOOL isInLeftPanningMode;
@property (atomic,readonly) TOOL_TYPE currentTool;
@property (nonatomic,strong) UIButton* selectedButton;
@property (nonatomic,strong) NSMutableArray* toolButtons;
@property (weak, nonatomic) IBOutlet UIView *bottomDock;
@property (weak, nonatomic) IBOutlet UIButton *colorButton;
-(id) initWithDelegate : (id<PencilcaseControllerDelegate>) delegate;
- (IBAction)onTouchColor:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *onTouchEndPaint;
-(void) animateToLeftPanning;
@end
