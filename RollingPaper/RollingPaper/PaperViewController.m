//
//  PaperViewController.m
//  RollingPaper
//
//  Created by 이상현 on 12. 11. 18..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "PaperViewController.h"
#import "NetworkTemplate.h"
#import "SBJSON.h"
#import "ImageContent.h"
#import "SoundContent.h"
#import "UECoreData.h"
#import "UELib/UEImageLibrary.h"
#import "ImageContentView.h"
#import "SoundContentView.h"
#import "UserInfo.h"
#import "CGPointExtension.h"
#import "ccMacros.h"
#import "UELib/UEUI.h"
#import "macro.h"
#import "RecoderViewController.h"

@interface PaperViewController ()
@end

@implementation PaperViewController
@synthesize paintingView;
@synthesize contentsViews;
@synthesize entity;
@synthesize friendPickerController;
@synthesize recoderViewController;
@synthesize cameraViewController;
@synthesize contentsContainer;
@synthesize transformTargetView;
-(id) initWithEntity : (RollingPaper*) aEntity
{
    self = [self initWithNibName:@"PaperViewController" bundle:NULL];
    if(self){
        self.entity   = aEntity;
        contentsViews = [[NSMutableArray alloc]init];
        NSLog(@"참여자 %d",self.entity.participants_count.intValue);
    }
    return self;
}

#define BORDER (10.0f)
- (void)setTransformTargetView:(UIView<RollingPaperContentViewProtocol> *)aTransformTargetView{
    if(transformTargetView){
        transformTargetView.layer.borderWidth = 0.0f;
    }
    
    transformTargetView = aTransformTargetView;
    transformTargetView.layer.borderWidth = BORDER;

    CGFloat components[4] = {0.8f,0.7f,0.1f,1.0f};
    transformTargetView.layer.borderColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), components);
}

-(void) initContentsEditingToolControlers{
    self.recoderViewController = [[RecoderViewController alloc]initWithDelegate:self];
    self.cameraViewController  = [[CameraViewController  alloc]initWithDelegate:self];
}
-(void) initLeftDockMenu{
    pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(onDockGesture)];
    pan.delegate = self.freeTransformGestureRecognizer;
    [self.view addGestureRecognizer:pan];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initContentsEditingToolControlers];
    
    self.freeTransformGestureRecognizer =
    [[UIFreeTransformGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(onFreeTransformGesture)];
    self.freeTransformGestureRecognizer.delegate = self.freeTransformGestureRecognizer;
    [self.contentsContainer addGestureRecognizer:self.freeTransformGestureRecognizer];
   
    /*
    UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onToggleDock)];
    tapGestureRecognizer.numberOfTapsRequired    = 1;
    tapGestureRecognizer.numberOfTouchesRequired = 2;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    */
    
    
    
    /*
    
    NSLog(@"%f",self.view.frame.size.height);
    UIViewSetY(self.menuDock,self.view.frame.size.height);
    [self.menuDock setHidden:TRUE];
     */
    
    ASIFormDataRequest* request = [NetworkTemplate requestForRollingPaperContents : self.entity.idx.stringValue
                                                                        afterTime : 1];
    [request setCompletionBlock:^{
        SBJSON* parser = [[SBJSON alloc]init];
        NSDictionary* categorizedContents = [parser objectWithString:request.responseString];
        NSLog(@"%@",categorizedContents);
        [self performSelectorOnMainThread : @selector(onReceiveContentsResponse:)
                               withObject : categorizedContents
                            waitUntilDone : TRUE];
    }];
    [request setFailedBlock:^{
        NSLog(@"--%@",request.error);
    }];
    [request startAsynchronous];
}

-(void) onDockGesture{
    CGRect frame = self.menuDock.frame;
    CGPoint translation = [pan translationInView:self.view];
    if(frame.origin.x >= 0)
    {
        //나온 상태
    }
    else
    {
        frame.origin.x += translation.x;
        if(frame.origin.x <= -frame.size.width)
            frame.origin.x = -frame.size.width;
        if(frame.origin.x >= 0)
            frame.origin.x = 0;
        self.menuDock.frame = frame;
        
        [pan setTranslation:CGPointMake(0, 0) inView:self.view];
    }
    if(pan.state == UIGestureRecognizerStateEnded){
        [UIView animateWithDuration:0.3f animations:^{
            CGRect frame = self.menuDock.frame;
            frame.origin.x = -frame.size.width;
            self.menuDock.frame = frame;
        } completion:^(BOOL finished) {
            
        }];
    }
}

-(void) onFreeTransformGesture{
    transformTargetView.center = ccpAdd(transformTargetView.center,
                                        self.freeTransformGestureRecognizer.translation);
    self.freeTransformGestureRecognizer.translation = CGPointZero;
    
    CGFloat scale = self.freeTransformGestureRecognizer.scale;
    transformTargetView.transform = CGAffineTransformScale(transformTargetView.transform,scale, scale);
    self.freeTransformGestureRecognizer.scale = 1.0f;
    self.transformTargetView.layer.borderWidth *= 1.0f/scale;
    
    CGFloat rotation = self.freeTransformGestureRecognizer.rotation;
    transformTargetView.transform = CGAffineTransformRotate(transformTargetView.transform,
                                                            rotation);
    self.freeTransformGestureRecognizer.rotation = 0.0f;
}
/*
-(void) onToggleDock{
    if(self.menuDock.isHidden){
        [self.menuDock setHidden:FALSE];
        [UIView animateWithDuration:0.3f
                         animations:^{
                             UIViewSetY(self.menuDock, self.view.frame.size.height - self.menuDock.frame.size.height);
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }else{
        [UIView animateWithDuration:0.3f
                         animations:^{
                             UIViewSetY(self.menuDock, self.view.frame.size.height);
                         }
                         completion:^(BOOL finished) {
                             [self.menuDock setHidden:TRUE];
                         }];
    }
}
*/
-(void) viewDidAppear:(BOOL)animated{

}
-(void) viewWillDisappear:(BOOL)animated{
    int i = 0;
    for( id<RollingPaperContentViewProtocol> view in self.contentsViews){
        if([view isNeedToSyncWithServer]){
            [view syncEntityWithServer];
            i++;
        }
    }
    NSLog(@"%d개 업데이트 되었습니다",i);
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) onReceiveContentsResponse : (NSDictionary*) categorizedContents{
    NSDictionary* imageContents = [categorizedContents objectForKey:@"image"];
    for(NSDictionary*p in imageContents){
        ImageContent* imageEntity = (ImageContent*)[[UECoreData sharedInstance]insertNewObject:@"ImageContent" initWith:p];
        ImageContentView* entityView = [[ImageContentView alloc] initWithEntity:imageEntity];
        [self.contentsContainer addSubview:entityView];
        [contentsViews addObject:entityView];
    }
    //NSDictionary* textContents  = [categorizedContents objectForKey:@"text"];
    
    
    NSDictionary* soundContents = [categorizedContents objectForKey:@"sound"];
    for(NSDictionary*p in soundContents){
        SoundContent* soundEntity = (SoundContent*)[[UECoreData sharedInstance]insertNewObject:@"SoundContent" initWith:p];
        SoundContentView* entityView = [[SoundContentView alloc] initWithEntity:soundEntity];
        [self.contentsContainer addSubview:entityView];
        [contentsViews addObject:entityView];
    }
    // 일단 받았음으로 받은 것을 현재 디바이스에 저장한다
}

- (IBAction)onTouchInvite:(id)sender {
    if(!friendPickerController){
        friendPickerController = [[FBFriendPickerViewController alloc] init];
        friendPickerController.title = @"Pick Friends";
        friendPickerController.delegate = self;
        
        [friendPickerController loadData];
        [friendPickerController clearSelection];
        [self presentViewController:friendPickerController animated:TRUE completion:^{
        
        }];
    }
}

-(void) facebookViewControllerDoneWasPressed:(id)sender{
    NSMutableArray* friendArray = [[NSMutableArray alloc]init];
    for (id<FBGraphUser> user in friendPickerController.selection) {
        [friendArray addObject: [user id]];
    }
    [self dismissViewControllerAnimated:TRUE completion:^{
        friendPickerController = NULL;
    }];
    @autoreleasepool {
        ASIFormDataRequest* request =  [NetworkTemplate requestForInviteFacebookFriends : friendArray
                                                                                ToPaper : [NSString stringWithFormat:@"%d",self.entity.idx.intValue]
                                                                               withUser : [UserInfo getUserIdx]];
        [request setCompletionBlock:^{
            NSLog(@"%@",request.responseString);
        }];
        [request setFailedBlock:^{
            NSLog(@"fail : ");
        }];
        [request startAsynchronous];
    }
}
- (IBAction)onTouchSound:(id)sender {        
    [self addChildViewController:self.recoderViewController];
    [self.view addSubview:self.recoderViewController.view];
    
    self.recoderViewController.view.alpha = 0.0f;
    [UIView animateWithDuration: 1.0f
                     animations:^{
                         self.recoderViewController.view.alpha = 1.0f;
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (IBAction)onAddImage:(id)sender {
    [self addChildViewController:self.cameraViewController];
    [self.view addSubview:self.cameraViewController.view];
    
    self.cameraViewController.view.alpha = 0.0f;
    [self.cameraViewController.view setHidden:FALSE];
    
    [UIView animateWithDuration: 1.0f
                     animations:^{
                         self.cameraViewController.view.alpha = 1.0f;
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (IBAction)onTouchBrush:(id)sender {
    [self.view bringSubviewToFront:paintingView];
    if(self.paintingView.frame.origin.x >= 0){
        UIImage* image = [paintingView glToUIImage];
        NSLog(@"%@",image);
        
        CGImageRef cgImage = image.CGImage;
        CGFloat width   = CGImageGetWidth(cgImage);
        CGFloat height  = CGImageGetHeight(cgImage);
        ImageContent* imageEntity = (ImageContent*)[[UECoreData sharedInstance]insertNewObject:@"ImageContent"];
        imageEntity.idx       = NULL;
        imageEntity.paper_idx = self.entity.idx;
        imageEntity.user_idx  = [NSNumber numberWithInt:[UserInfo getUserIdx].intValue];
        imageEntity.x         = [NSNumber numberWithFloat:0];
        imageEntity.y         = [NSNumber numberWithFloat:0];
        imageEntity.rotation  = [NSNumber numberWithFloat:0.0f];
        imageEntity.image     = NULL;
        imageEntity.width     = [NSNumber numberWithFloat:width];
        imageEntity.height    = [NSNumber numberWithFloat:height];
        
        ImageContentView* entityView = [[ImageContentView alloc] initWithEntity:imageEntity];
        entityView.isNeedToSyncWithServer = TRUE;
        entityView.image = image;
        [self.contentsContainer addSubview:entityView];
        [self.contentsViews addObject:entityView];
        
        transformTargetView = entityView;
        
        UIViewSetX(paintingView, -10000);
        [paintingView erase];
    }
    else {
        [self.view bringSubviewToFront:paintingView];
        UIViewSetX(paintingView, 0);
    }
}

-(void) CameraViewController : (CameraViewController *)recoder
                 onpickImage : (UIImage *)image{
    CGImageRef cgImage = image.CGImage;
    CGFloat width   = CGImageGetWidth(cgImage);
    CGFloat height  = CGImageGetHeight(cgImage);
    
    ImageContent* imageEntity = (ImageContent*)[[UECoreData sharedInstance]insertNewObject:@"ImageContent"];
    imageEntity.idx       = NULL;
    imageEntity.paper_idx = self.entity.idx;
    imageEntity.user_idx  = [NSNumber numberWithInt:[UserInfo getUserIdx].intValue];
    imageEntity.x         = [NSNumber numberWithFloat:0.0f];
    imageEntity.y         = [NSNumber numberWithFloat:0.0f];
    imageEntity.rotation  = [NSNumber numberWithFloat:0.0f];
    imageEntity.image     = NULL;
    imageEntity.width     = [NSNumber numberWithFloat:width];
    imageEntity.height    = [NSNumber numberWithFloat:height];
    
    ImageContentView* entityView = [[ImageContentView alloc] initWithEntity:imageEntity];
    entityView.isNeedToSyncWithServer = TRUE;
    entityView.image = image;
    [self.contentsContainer addSubview:entityView];
    [self.contentsViews addObject:entityView];
    
    self.transformTargetView = entityView;
    
    [UIView animateWithDuration: 1.0f
                     animations:^{
                         self.cameraViewController.view.alpha = 0.0f;
                     } completion:^(BOOL finished) {
                         [self.cameraViewController.view setHidden:TRUE];
                     }];
}
-(void) RecoderViewController : (RecoderViewController *)recoder
        onEndRecodingWithFile : (NSString *)file{
    
    SoundContent* soundEntity = (SoundContent*)[[UECoreData sharedInstance]insertNewObject:@"SoundContent"];
    soundEntity.idx       = NULL;
    soundEntity.paper_idx = self.entity.idx;
    soundEntity.user_idx  = [NSNumber numberWithInt:[UserInfo getUserIdx].intValue];
    soundEntity.x         = [NSNumber numberWithFloat:self.view.frame.size.width/2 ];
    soundEntity.y         = [NSNumber numberWithFloat:self.view.frame.size.height/2];
    soundEntity.sound     = [file mutableCopy];
    
    SoundContentView* entityView = [[SoundContentView alloc] initWithEntity:soundEntity];
    entityView.isNeedToSyncWithServer = TRUE;
    [self.view addSubview:entityView];
    [self.contentsViews addObject:entityView];
    
    transformTargetView = entityView;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if (event.type    == UIEventTypeMotion &&
        event.subtype == UIEventSubtypeMotionShake) {
        [self.navigationController popViewControllerAnimated:TRUE];
    }
}
- (BOOL)canBecomeFirstResponder{
    return YES;
}

- (void)viewDidUnload {
    [self setMenuDock:nil];
    [self setContentsContainer:nil];
    [super viewDidUnload];
}
@end
