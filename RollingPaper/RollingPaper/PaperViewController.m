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
#import "RecoderController.h"
#import "CameraController.h"
#import "AlbumController.h"
#import "PencilcaseController.h"

@interface PaperViewController ()
@end

@implementation PaperViewController
@synthesize paintingView;
@synthesize contentsViews;
@synthesize entity;
@synthesize friendPickerController;
@synthesize contentsContainer;
@synthesize transformTargetView;
@synthesize dockController;

-(id) initWithEntity : (RollingPaper*) aEntity
{
    self = [self initWithNibName:NSStringFromClass(self.class) bundle:NULL];
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
    else{
    }
    
    transformTargetView = aTransformTargetView;
    
    if(transformTargetView)
    {
        transformTargetView.layer.borderWidth = BORDER;
        
        CGFloat components[4] = {0.8f,0.7f,0.1f,1.0f};
        transformTargetView.layer.borderColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), components);
        self.freeTransformGestureRecognizer.enabled = TRUE;
        self.dockController.panGestureRecognizer.enabled = FALSE;
    }
    else {
        self.freeTransformGestureRecognizer.enabled = FALSE;
        self.dockController.panGestureRecognizer.enabled = TRUE;
    }
}

-(void) initContentsEditingToolControlers{
    
    self.freeTransformGestureRecognizer =
    [[UIFreeTransformGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(onFreeTransformGesture)];
    self.freeTransformGestureRecognizer.delegate = self.freeTransformGestureRecognizer;
    [self.contentsContainer addGestureRecognizer:self.freeTransformGestureRecognizer];
}
-(void) initLeftDockMenu{
    self.dockController = [[DockController alloc]initWithDelegate:self];
    [self addChildViewController:self.dockController];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initContentsEditingToolControlers];
    [self initLeftDockMenu];
    
    
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


-(void) onFreeTransformGesture{
    NSLog(@"%f %f : %f %f",transformTargetView.center.x,transformTargetView.center.y,self.freeTransformGestureRecognizer.translation.x,self.freeTransformGestureRecognizer.translation.y);
    
    transformTargetView.center = ccpAdd(transformTargetView.center,
                                        self.freeTransformGestureRecognizer.translation);
    self.freeTransformGestureRecognizer.translation = CGPointZero;
    
    CGFloat scale = self.freeTransformGestureRecognizer.scale;

    CGRect bounds = transformTargetView.bounds;
    bounds.size.width  *= scale;
    bounds.size.height *= scale;
    transformTargetView.bounds = bounds;
    
    self.freeTransformGestureRecognizer.scale = 1.0f;
    
    
    CGFloat rotation = self.freeTransformGestureRecognizer.rotation;
    transformTargetView.transform = CGAffineTransformRotate(transformTargetView.transform,
                                                            rotation);
    self.freeTransformGestureRecognizer.rotation = 0.0f;
    NSLog(@"%f %f",scale,rotation);
    
    if(transformTargetView){
        transformTargetView.isNeedToSyncWithServer = TRUE;
    }
}
-(void) onLongPressContent : (UILongPressGestureRecognizer*) gestureRecognizer{
//    [UEUI ziggleAnimation:gestureRecognizer.view];
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        if(gestureRecognizer.view == transformTargetView)
        {
            [self setTransformTargetView:NULL];
        }
        else{
            [self setTransformTargetView:gestureRecognizer.view];
        }
    }
}
-(void) onReceiveContentsResponse : (NSDictionary*) categorizedContents{
    NSDictionary* imageContents = [categorizedContents objectForKey:@"image"];
    for(NSDictionary*p in imageContents){
        ImageContent* imageEntity = (ImageContent*)[[UECoreData sharedInstance]insertNewObject:@"ImageContent" initWith:p];
        ImageContentView* entityView = [[ImageContentView alloc] initWithEntity:imageEntity];
        [self.contentsContainer addSubview:entityView];
        [contentsViews addObject:entityView];
        
        entityView.userInteractionEnabled = TRUE;
        UILongPressGestureRecognizer* longTapGestureRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self
                                                                                                              action:@selector(onLongPressContent:)];
        [entityView addGestureRecognizer:longTapGestureRecognizer];
        longTapGestureRecognizer.delegate = self;
        NSLog(@"%@",longTapGestureRecognizer);
    }
    self.transformTargetView = [contentsViews lastObject];
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

-(void) onCreateImage : (UIImage *)image{
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
}
-(BOOL) canBecomeFirstResponder{
    return YES;
}
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if (event.type    == UIEventTypeMotion &&
        event.subtype == UIEventSubtypeMotionShake) {
        [self.navigationController popViewControllerAnimated:TRUE];
    }
}
- (void)viewDidUnload {
    [self setContentsContainer:nil];
    [super viewDidUnload];
}

-(BOOL) gestureRecognizer : (UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer : (UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

-(void) dockController:(DockController *)dock
              pickMenu:(DockMenuType)menuType
              inButton:(UIButton *)button{
    NSLog(@"%@ %d %@",dock,menuType,button);
    switch (menuType) {
        case DockMenuTypeCamera:{
            CameraController* camViewController = [[CameraController alloc] initWithDelegate:self];
            [self addChildViewController:camViewController];
            [self.view addSubview:camViewController.view];
        }break;
        case DockMenuTypeAlbum:{
            [UIView animateWithDuration:1.0f
                             animations:^{
                                 UIViewSetOrigin(button, CGPointMake(0, 0));
                             } completion:^(BOOL finished) {
                                 AlbumController* albumController = [[AlbumController alloc]initWithDelegate:self];
                                 [self addChildViewController:albumController];
                                 [self.view addSubview:albumController.view];
                             }];
        }break;
        case DockMenuTypeKeyboard : {
            TypewriterController* typewriterController = [[TypewriterController alloc]initWithDelegate:self];
            [self addChildViewController:typewriterController];
            [self.view addSubview:typewriterController.view];
        }break;
        case DockMenuTypeMicrophone: {
            RecoderController* recoderController = [[RecoderController alloc] initWithDelegate:self];
            [self addChildViewController:recoderController];
            [self.view addSubview:recoderController.view];
            recoderController.view.alpha = 0.0f;
            [UIView animateWithDuration:0.4f animations:^{
                recoderController.view.alpha = 1.0f;
            }];
        }break;
        case DockMenuTypePencilcase: {
            PencilcaseController* pencilcaseController =
            [[PencilcaseController alloc]initWithNibName:@"PencilcaseController"
                                                  bundle:NULL];
            [self addChildViewController:pencilcaseController];
            [self.view addSubview:pencilcaseController.view];
            
        }break; 
        default:
            break;
    }
}
-(void) cameraController:(CameraController *)camera
             onPickImage:(UIImage *)image{
    if(image){
        //이미지를 선택한경우
        [self onCreateImage:image];
    }
    else {
        //취소한경우
    }
    [camera removeFromParentViewController];
    [camera.view removeFromSuperview];
}
-(void) albumController:(AlbumController *)albumController
              pickImage:(UIImage *)image
               withInfo:(NSDictionary *)infodict{
    if(image){
        //이미지를 선택한경우
        [self onCreateImage:image];
    }
    else {
        //취소한경우
    }
    [albumController removeFromParentViewController];
    [albumController.view removeFromSuperview];
}
-(void) typewriterController:(TypewriterController *)typewriterController
                endEditImage:(UIImage *)image{
    
    [self onCreateImage:image];
    [typewriterController removeFromParentViewController];
    [typewriterController.view removeFromSuperview];

}
-(void) RecoderViewController : (RecoderController *)recoder
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
    
    self.transformTargetView = entityView;
}
@end
