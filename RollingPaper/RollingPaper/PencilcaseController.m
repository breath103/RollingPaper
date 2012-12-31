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
#import "UELib/UEImageLibrary.h"
#import "PaintingView.h"

/*
 연필 : X: -85.5  /  Y:182 /  W:216.5  / H: 23.5 / 30도
 모나미 펜 : X: -82  /  Y:205.5 /  W: 231  / H: 20   / 15도
 사인펜 X:-19  /  Y: 231.5 /  W:193.5  / H:28.5 / 0도
 크레용 X:-11.5 /  Y: 296 /  W: 151.5 / H: 23.5 / -15도
 형광펜 X:-32.5  /  Y:313.5 /  W:164.5  / H:31.5 / -30도
 */


CGSize ToolImageSize[TOOL_COUNT] = {
    { 217  , 19.5},
    { 231  , 20},
    { 186.5, 26},
    { 178  , 24},
    { 164  , 32.5}
};
NSString* TOOL_TYPE_STRING[TOOL_COUNT] = {
    @"pencil",
    @"ballpen",
    @"namepen",
    @"crayon",
    @"lightpen"
};

@interface PencilcaseController ()

@end

@implementation PencilcaseController
@synthesize toolButtons;
@synthesize paintingView;
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

- (void) initColorPopover{
    self.colorPalette.delegate = self;
    NSMutableArray* colors = [NSMutableArray arrayWithObjects: UIColorXRGB(0,0,0),
                                                 UIColorXRGB(255,30,0),
                                                 UIColorXRGB(246,207,40),
                                                 UIColorXRGB(94,116,62),
                                                 UIColorXRGB(58,81,96),
                                                 UIColorXRGB(98,77,149),
                                                 UIColorXRGB(255,0,102), nil];
    [self.colorPalette createColorButtonsWithColors:colors];
    NSLog(@"%@\%@",self.colorPalette,self.colorPalette.backgroundColor);
}
- (void) initBottomDock{
    UIViewSetY(self.bottomDock,self.view.bounds.size.height);
    
    colorButton.layer.cornerRadius = colorButton.bounds.size.width / 2.0f;
    colorButton.layer.borderWidth  = 3.0f;
    colorButton.layer.borderColor  = [UIColor whiteColor].CGColor;
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.paintingView = [[PaintingView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:self.paintingView];
    [self.view sendSubviewToBack:self.paintingView];
    NSLog(@"%@",self.paintingView);
    
    selectedButton = NULL;
    
    [self initToolButtons];
    [self initBottomDock];
    [self initColorPopover];
    
    [self animateToLeftPanning];
}
-(IBAction)onToolTouched:(id)sender{
    
    if(isInLeftPanningMode){
        TOOL_TYPE newTool = (TOOL_TYPE)((UIButton*)sender).tag;
        [self.paintingView setToolType:newTool];
        
        
        if(selectedButton){
            [UIView animateWithDuration:1.0f animations:^{
                selectedButton.layer.shadowOpacity = 0.0f;
            }];
        }
        
        [UIView animateWithDuration:0.5f animations:^{
            self.view.backgroundColor = [UIColor clearColor];
        }];
        selectedButton = sender;
        [self showBottomDock];
        [UIView animateWithDuration:0.5f
                         animations:^{
                             self.selectedButton.layer.shadowRadius = 5.0;
                             self.selectedButton.layer.shadowOffset = CGSizeMake(0,0);
                             self.selectedButton.layer.shadowOpacity = 1.0f;
                             self.selectedButton.layer.shadowColor = [UIColor whiteColor].CGColor;
                             self.selectedButton.layer.shouldRasterize = YES;
                             self.selectedButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
                             
                             for(UIButton* button in toolButtons)
                             {
                                 button.transform = CGAffineTransformMakeRotation(CC_DEGREES_TO_RADIANS(-90));
                                 if(button != sender)
                                 {
                                     button.center =  CGPointMake(97,self.view.bounds.size.height);
                                 }else{
                                     button.center =  CGPointMake(97,self.view.bounds.size.height - self.bottomDock.bounds.size.height);
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
-(void) initToolButtons{
    toolButtons = [[NSMutableArray alloc]initWithCapacity:TOOL_COUNT];
    for(int i=0;i<TOOL_COUNT;i++){
        UIButton* button = [self buttonWithToolType:i];
        button.tag = (TOOL_TYPE)i;
        
        [button addTarget : self
                   action : @selector(onToolTouched:)
         forControlEvents : UIControlEventTouchUpInside];
        
        [self.view addSubview:button];
        [toolButtons addObject:button];
    }
}
-(UIButton*) buttonWithToolType : (TOOL_TYPE) toolType{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    NSString* imageName = TOOL_TYPE_STRING[toolType];
    
    CGSize size = ToolImageSize[toolType];
    
    UIImage* image      = [UIImage imageNamed:imageName];
    UIImage* mask_Image = [UIImage imageNamed:[imageName stringByAppendingString:@"_mask"]];
    
    button.contentMode = UIViewContentModeScaleToFill;
    [button setImage:image
            forState:UIControlStateNormal];
    NSLog(@"%@ %@",image,mask_Image);
    
   // CGSize size = CGSizeMake(300, 40);//image.size;
    UIViewSetSize(button, size);
    button.layer.anchorPoint = ccp(1,0.5);
    button.center = CGPointMake(-size.width, self.view.bounds.size.height/2);
    
    if(mask_Image)
    {
        UIView* colorOverlayView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, size.width,size.height)];
        colorOverlayView.opaque = NO;
        colorOverlayView.backgroundColor = [UIColor redColor];
        CALayer* maskLayer = [CALayer layer];
        maskLayer.frame = CGRectMake(0,0,size.width,size.height);
        maskLayer.contents = (__bridge id)[mask_Image CGImage];
        colorOverlayView.layer.mask = maskLayer;
        colorOverlayView.userInteractionEnabled = FALSE;
        colorOverlayView.tag = 1000;
        [button addSubview:colorOverlayView];
    }
    return button;
}

-(IBAction)onSelectColor:(id)sender{
    UIButton* button = sender;
    NSLog(@"%@",button.backgroundColor);
   // self.paintingView.currentTemplate.lineColor = button.backgroundColor;
    self.paintingView.lineColor = button.backgroundColor;
    [UIView animateWithDuration:0.5f animations:^{
        [self.selectedButton viewWithTag:1000].backgroundColor = button.backgroundColor;
    } completion:^(BOOL finished) {
        
    }];
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
    //self.colorPaletteController.view.hidden = FALSE;
    self.colorPalette.hidden = FALSE;
}

-(void) colorPalette : (ColorPalette *)palette
         selectColor : (UIColor *)color{
    self.paintingView.lineColor = color;
    
    self.colorButton.backgroundColor = color;
    
    NSLog(@"%@",color);
}


- (IBAction)onTouchEndPaint:(id)sender {
    //그림 완료를 눌렀을때의 액션
    UIImage* brushedImage = [self.paintingView toImage];
    if(brushedImage)
    {
        [self.delegate pencilcaseController:self
                            didEndDrawImage:brushedImage
                                     inRect:[self.paintingView UIPaintedRect]];
    }
    else{
        [self.delegate pencilcaseControllerdidCancelDraw:self];
    }
}

-(void) animateToLeftPanning{
    isInLeftPanningMode = true;
    int count = toolButtons.count;
    
    
    [self hideBottomDock];
    CGPoint leftOrigin = ccp(-100,self.view.frame.size.height/2);
    [UIView animateWithDuration:0.5f
                     animations:^{
                         int index = 0;
                         for(UIButton* button in toolButtons)
                         {
                             button.enabled   = TRUE;
                             float rotation = CC_DEGREES_TO_RADIANS( (index - count/2) * 60.0/(count-1));
                             button.center    = ccpAdd(leftOrigin,ccpMult(ccpForAngle(rotation),250));
                             button.transform = CGAffineTransformMakeRotation(rotation);
                            
                             index++;
                         }
                         
                         self.view.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
                     }
                     completion:^(BOOL finished) {
                     }];
    isInLeftPanningMode = TRUE;
    
}

- (IBAction)onTouchUndo:(id)sender {
    [self.paintingView undo];
}
- (IBAction)onTouchRedo:(id)sender {
    [self.paintingView redo];
}
- (IBAction)onTouchClear:(id)sender {
    [self.paintingView clearWithAnimation: TRUE];
}



- (void)viewDidUnload {
    [self setBottomDock:nil];
    [self setColorButton:nil];
    [self setColorPalette:nil];
    [super viewDidUnload];
}
@end
