//
//  DockController.m
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 18..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "DockController.h"
#import "macro.h"

@interface DockController ()

@end

@implementation DockController
@synthesize isDockPoped;
@synthesize delegate;
@synthesize panGestureRecognizer;
-(id) initWithDelegate:(id<DockControllerDelegate>)aDelegate{
    self = [self initWithNibName:NSStringFromClass(self.class)
                          bundle:NULL];
    if(self){
        self.delegate = aDelegate;
    }
    return self;
}

-(void) willMoveToParentViewController:(UIViewController *)parent{
    [self.parentViewController.view addSubview:self.view];
    UIViewSetOrigin(self.view, CGPointMake(-self.view.frame.size.width,0));
    self.panGestureRecognizer = [[ UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onDockGesture:)];
    [parent.view addGestureRecognizer:self.panGestureRecognizer];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) hide{
    isDockPoped = FALSE;
    [UIView animateWithDuration:0.1f animations:^{
        UIViewSetX(self.view,-self.view.frame.size.width);
    } completion:^(BOOL finished) {
    }];
}
-(void) show{
    [UIView animateWithDuration:0.1f animations:^{
        UIViewSetX(self.view, 0);
    } completion:^(BOOL finished) {
        isDockPoped = TRUE;
    }];
}
-(void) onDockGesture : (UIPanGestureRecognizer*) gestureRecognizer{
    CGRect frame = self.view.frame;
    CGPoint translation = [gestureRecognizer translationInView:nil];
    if(frame.origin.x >= 0)
        isDockPoped = TRUE;
    else
        isDockPoped = FALSE;
    frame.origin.x += translation.x;
    if(frame.origin.x <= -frame.size.width)
        frame.origin.x = -frame.size.width;
    if(frame.origin.x >= 0)
        frame.origin.x = 0;
    self.view.frame = frame;
    
    [gestureRecognizer setTranslation:CGPointMake(0, 0) inView:nil];
    
    if(gestureRecognizer.state == UIGestureRecognizerStateEnded){
        float threadhold = 0.7f;
        if( frame.origin.x + frame.size.width < frame.size.width * threadhold){
            [self hide];
        }else{
            [self show];
        }
    }
}


- (IBAction)onTouchCamera:(id)sender{
    NSLog(@"Camera Menu");
    [self.delegate dockController:self
                         pickMenu:DockMenuTypeCamera
                         inButton:sender];
}
- (IBAction)onTouchAlbum:(id)sender{
    NSLog(@"Album Menu");
    [self.delegate dockController:self
                         pickMenu:DockMenuTypeAlbum
                         inButton:sender];

}
- (IBAction)onTouchKeyboard:(id)sender{
    NSLog(@"Keyboard Menu");
    [self.delegate dockController : self
                         pickMenu : DockMenuTypeKeyboard
                         inButton : sender];
}

- (IBAction)onTouchMicrophone:(id)sender{
    NSLog(@"Microphone Menu");
    [self.delegate dockController : self
                         pickMenu : DockMenuTypeMicrophone
                         inButton : sender];
}
- (IBAction)onTouchPencilcase:(id)sender{
    NSLog(@"Pencilecase Menu");
    [self.delegate dockController : self
                         pickMenu : DockMenuTypePencilcase
                         inButton : sender];
}


@end
