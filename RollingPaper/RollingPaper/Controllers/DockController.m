
#import "DockController.h"
#import "ccMacros.h"
#import "UIView+AnimationMacro.h"

@interface DockController ()

@end

@implementation DockController
@synthesize panGestureRecognizer;
-(id) initWithDelegate:(id<DockControllerDelegate>)aDelegate{
    self = [self initWithNibName:NSStringFromClass(self.class)
                          bundle:NULL];
    if(self){
        _delegate = aDelegate;
    }
    return self;
}

-(void) willMoveToParentViewController:(UIViewController *)parent{
    [self.parentViewController.view addSubview:self.view];
    [self.view setOrigin:CGPointMake(-self.dockView.bounds.size.width,
                                     parent.view.frame.size.height / 2 - self.view.bounds.size.height / 2)];
    self.panGestureRecognizer = [[ UIPanGestureRecognizer alloc] initWithTarget:self
                                                                         action:@selector(onDockGesture:)];
    [parent.view addGestureRecognizer:self.panGestureRecognizer];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self view] viewWithTag:10].transform = CGAffineTransformMakeRotation(CC_DEGREES_TO_RADIANS(-15));
    [[self view] viewWithTag:15].transform = CGAffineTransformMakeRotation(CC_DEGREES_TO_RADIANS(-30));
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) hide{
    _isDockPoped = NO;
    [UIView animateWithDuration:0.1f animations:^{
        [self.view setLeft:-self.dockView.bounds.size.width];
    } completion:^(BOOL finished) {
    }];
}
-(void) show{
    [UIView animateWithDuration:0.1f animations:^{
        [[self view] setLeft:0];
    } completion:^(BOOL finished) {
        _isDockPoped = YES;
    }];
}
-(void) onDockGesture : (UIPanGestureRecognizer*) gestureRecognizer{
    CGRect frame = self.view.frame;
    CGPoint translation = [gestureRecognizer translationInView:nil];
    if(frame.origin.x >= 0)
        _isDockPoped = YES;
    else
        _isDockPoped = NO;
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


- (IBAction)onTouchCamera:(id)sender
{
    [self.delegate dockController:self
                         pickMenu:DockMenuTypeCamera
                         inButton:sender];
}
- (IBAction)onTouchAlbum:(id)sender
{
    [self.delegate dockController:self
                         pickMenu:DockMenuTypeAlbum
                         inButton:sender];
 
}
- (IBAction)onTouchKeyboard:(id)sender
{
    [self.delegate dockController : self
                         pickMenu : DockMenuTypeKeyboard
                         inButton : sender];
}

- (IBAction)onTouchMicrophone:(id)sender
{
    [self.delegate dockController : self
                         pickMenu : DockMenuTypeMicrophone
                         inButton : sender];
}
- (IBAction)onTouchPencilcase:(id)sender
{
    [self.delegate dockController : self
                         pickMenu : DockMenuTypePencilcase
                         inButton : sender];
}
- (IBAction)onTouchSetting:(id)sender
{
    [self.delegate dockController : self
                         pickMenu : DockMenuTypeSetting
                         inButton : sender];

}

- (IBAction)onTouchShowToggleButton:(id)sender {
    if(_isDockPoped){
        [self hide];
    }
    else{
        [self show];
    }
}

-(void) hideIndicator{
    [self.view fadeOut:0.1f];
}

-(void) showIndicator{
    [self.view fadeIn:0.1f];
}

@end
