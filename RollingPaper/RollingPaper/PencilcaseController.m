//
//  PencilcaseController.m
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 19..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "PencilcaseController.h"
#import "ccMacros.h"
#import <QuartzCore/QuartzCore.h>
#import "CGPointExtension.h"
#import "macro.h"
#import "UELib/UEUI.h"

@interface PencilcaseController ()

@end

@implementation PencilcaseController
@synthesize toolButtons;
@synthesize currentTool;
@synthesize selectedButton;
@synthesize isInLeftPanningMode;
@synthesize bottomDock;
@synthesize colorButton;
@synthesize delegate;
-(id) initWithDelegate : (id<PencilcaseControllerDelegate>) aDelegate{
    self = [self initWithNibName:NSStringFromClass(self.class) bundle:NULL];
    if(self){
        self.delegate = aDelegate;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    selectedButton = NULL;
    toolButtons = [[NSMutableArray alloc]initWithCapacity:TOOL_COUNT];
    for(int i=0;i<TOOL_COUNT;i++){
        UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"sharp"]
                forState:UIControlStateNormal];
        CGSize size = CGSizeMake(200, 100);
   
        button.tag = (TOOL_TYPE)i;
        button.layer.anchorPoint = ccp(0,0.5);
        button.bounds = CGRectMake (0, 0, size.width, size.height);
        button.center = CGPointMake(-size.width, self.view.bounds.size.height/2);
        
        [button addTarget : self
                   action : @selector(onToolTouched:)
         forControlEvents : UIControlEventTouchUpInside];
        
        [self.view addSubview:button];
        [toolButtons addObject:button];
    }
    
    UIViewSetY(self.bottomDock,self.view.bounds.size.height);
    colorButton.layer.cornerRadius = colorButton.bounds.size.width / 2.0f;
    colorButton.layer.borderWidth  = 3.0f;
    colorButton.layer.borderColor  = [UIColor whiteColor].CGColor;
    [self animateToLeftPanning];
}
-(IBAction)onToolTouched:(id)sender{
    
    if(isInLeftPanningMode){
        currentTool = (TOOL_TYPE)((UIButton*)sender).tag;
        
        if(selectedButton){
            [UIView animateWithDuration:1.0f animations:^{
                selectedButton.layer.shadowOpacity = 0.0f;
            }];
        }
        selectedButton = sender;
        [self showBottomDock];
        [UIView animateWithDuration:0.5f
                         animations:^{
                             {
                                 self.selectedButton.layer.shadowRadius = 5.0;
                                 self.selectedButton.layer.shadowOffset = CGSizeMake(0,0);
                                 self.selectedButton.layer.shadowOpacity = 1.0f;
                                 self.selectedButton.layer.shadowColor = [UIColor whiteColor].CGColor;
                                 self.selectedButton.layer.shouldRasterize = YES;
                                 self.selectedButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
                             }
                             for(UIButton* button in toolButtons)
                             {
                                 button.transform = CGAffineTransformMakeRotation(CC_DEGREES_TO_RADIANS(-90));
                                 if(button != sender)
                                 {
                                     button.center =  CGPointMake(50,self.view.bounds.size.height + button.bounds.size.width);
                                 }else{
                                     button.center =  CGPointMake(50,self.view.bounds.size.height + button.bounds.size.width - self.bottomDock.bounds.size.height);
                                 }
                             }
                             //UIViewSetY(sender, self.view.frame.size.height - 30);
                         } completion:^(BOOL finished) {
                             
                         }];
        isInLeftPanningMode = FALSE;
    }
    else{
        [self animateToLeftPanning];
    }
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) showBottomDock{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         UIViewSetY(self.bottomDock,self.view.bounds.size.height - self.bottomDock.bounds.size.height);
                     } completion:^(BOOL finished) {
                            
                     }];
}
-(void) hideBottomDock{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         UIViewSetY(self.bottomDock,self.view.bounds.size.height);
                     } completion:^(BOOL finished) {
                         
                     }];
    
}

- (IBAction)onTouchColor:(id)sender {
    NSLog(@"Color Touched");
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

-(void) animateToLeftPanning{
    isInLeftPanningMode = true;
    int count = toolButtons.count;
    int index = 0;
    [self hideBottomDock];
    for(UIButton* button in toolButtons)
    {
        button.enabled = TRUE;
            [UIView animateWithDuration:0.5f
                             animations:^{
                                 button.center = CGPointMake(-button.bounds.size.width * 0.4, self.view.bounds.size.height/2);
                                 button.transform = CGAffineTransformMakeRotation(CC_DEGREES_TO_RADIANS(index-count/2) * (60/count));
                             } completion:^(BOOL finished) {
                             }];
        index++;
    }
    isInLeftPanningMode = TRUE;
}
- (void)viewDidUnload {
    [self setBottomDock:nil];
    [self setColorButton:nil];
    [self setOnTouchEndPaint:nil];
    [super viewDidUnload];
}
-(void) motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    
}
-(void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    
}
@end
