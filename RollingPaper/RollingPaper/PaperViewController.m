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
//#import "CameraController.h"
#import "AlbumController.h"
#import "PencilcaseController.h"
#import "BlockSupport/NSObject+block.h"
#import <QuartzCore/QuartzCore.h>
#import "UEFileManager.h"


#define BORDER (10.0f)

@interface PaperViewController ()
@end

@implementation PaperViewController
//@synthesize contentsViews;
@synthesize entity;
@synthesize friendPickerController;
@synthesize contentsContainer;
@synthesize transformTargetView = _transformTargetView;
@synthesize dockController;
@synthesize contentsScrollContainer;
@synthesize isEditingMode;
-(id) initWithEntity : (RollingPaper*) aEntity{
    self = [self initWithNibName:NSStringFromClass(self.class) bundle:NULL];
    if(self){
        self.entity = aEntity;
    }
    return self;
}
-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //사용자가 한번 본 경우에는 해당 엔티티가 더이상 새로운 것이 아니기 때문에 NO로 변경
    self.entity.is_new = [NSNumber numberWithBool:NO];
}
-(void) initContentsEditingToolControlers{
    self.freeTransformGestureRecognizer = [[UIFreeTransformGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(onFreeTransformGesture)];
    self.freeTransformGestureRecognizer.delegate = self.freeTransformGestureRecognizer;
    [self.contentsContainer addGestureRecognizer:self.freeTransformGestureRecognizer];
}
-(void) initLeftDockMenu{
    self.dockController = [[DockController alloc]initWithDelegate:self];
    [self addChildViewController:self.dockController];
}
-(void) initContentsScrollContainer{
    self.contentsContainer.contentSize = CGSizeMake(self.entity.width.floatValue,
                                                    self.entity.height.floatValue);
    self.contentsScrollContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                                            self.entity.width.floatValue,
                                                                            self.entity.height.floatValue)];

    NSData* backgroundData = [UEFileManager readDataFromLocalFile:[NSString stringWithFormat:@"paperbg_%@",entity.background]];
    if(backgroundData){
        NSLog(@"%@가 로컬에 있음",entity.background);
        self.contentsScrollContainer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageWithData:backgroundData]];
    }
    else{
        NSLog(@"%@가 로컬에 없음",entity.background);
        
        [NetworkTemplate getBackgroundImage:entity.background
                                withHandler:^(UIImage *image) {
                                    self.contentsScrollContainer.backgroundColor = [UIColor colorWithPatternImage:image];
                                    [self.contentsScrollContainer setNeedsDisplay];
                                }];
     
    }
    ///
    
    self.contentsScrollContainer.userInteractionEnabled = TRUE;
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                                action:@selector(onTapScrollBack:)];
    // tapGesture.delegate = self;
    [self.contentsScrollContainer addGestureRecognizer:tapGesture];

    [self.contentsContainer addSubview:self.contentsScrollContainer];
    self.contentsContainer.scrollEnabled = FALSE;
    self.contentsContainer.delegate = self;
}
-(void) onReceiveContentsResponse : (NSDictionary*) categorizedContents{
    NSDictionary* imageContents = [categorizedContents objectForKey:@"image"];
    for(NSDictionary*p in imageContents){
        ImageContent* imageEntity = (ImageContent*)[[UECoreData sharedInstance]insertNewObject:@"ImageContent" initWith:p];
        ImageContentView* entityView = [[ImageContentView alloc] initWithEntity:imageEntity];
        [self.contentsScrollContainer addSubview:entityView];
        
        [self addTransformTargetGestureToEntityView:entityView];
    }
    //self.transformTargetView = [contentsViews lastObject];
    //NSDictionary* textContents  = [categorizedContents objectForKey:@"text"];
    
    NSDictionary* soundContents = [categorizedContents objectForKey:@"sound"];
    for(NSDictionary*p in soundContents){
        SoundContent* soundEntity = (SoundContent*)[[UECoreData sharedInstance]insertNewObject:@"SoundContent" initWith:p];
        SoundContentView* entityView = [[SoundContentView alloc] initWithEntity:soundEntity];
        [self.contentsScrollContainer addSubview:entityView];
    }
    // 일단 받았음으로 받은 것을 현재 디바이스에 저장한다
}
-(void)loadAndShowContents{
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

-(void)viewDidLoad{
    [super viewDidLoad];
    
    self.contentsContainer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"main_background"]];
    [self initContentsEditingToolControlers];
    [self initLeftDockMenu];
    [self initContentsScrollContainer];
    [self loadAndShowContents];
    [self onChangeToEditingMode];
    
    self.transformTargetView = NULL;
}


-(void) onTapScrollBack : (UITapGestureRecognizer*) tap{
    if(tap.state == UIGestureRecognizerStateBegan){
        self.transformTargetView = NULL;
        NSLog(@"Long Background : %@",tap);
    }
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
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

-(NSArray*) contentsViews{
    return self.contentsScrollContainer.subviews;
}

#pragma mark FreeTransfromGesutreRecognizers 처리를 위한 함수들과 트랜스폼 타겟 뷰를 설정했을때 테두리 보여주는 부분
-(void) onFreeTransformGesture{
    self.transformTargetView.center = ccpAdd(self.transformTargetView.center,
                                             self.freeTransformGestureRecognizer.translation);
    self.freeTransformGestureRecognizer.translation = CGPointZero;
    
    CGFloat scale = self.freeTransformGestureRecognizer.scale;

    CGRect bounds = self.transformTargetView.bounds;
    bounds.size.width  *= scale;
    bounds.size.height *= scale;
    self.transformTargetView.bounds = bounds;
    
    self.freeTransformGestureRecognizer.scale = 1.0f;
    
    
    CGFloat rotation = self.freeTransformGestureRecognizer.rotation;
    self.transformTargetView.transform = CGAffineTransformRotate(self.transformTargetView.transform,
                                                            rotation);
    self.freeTransformGestureRecognizer.rotation = 0.0f;
    
    if(self.transformTargetView){
        self.transformTargetView.isNeedToSyncWithServer = TRUE;
    }
}
-(void) setTransformTargetView:(UIView<RollingPaperContentViewProtocol> *)aTransformTargetView{
    if(_transformTargetView){
        _transformTargetView.layer.borderWidth = 0.0f;
    }
    
    _transformTargetView = aTransformTargetView;
    if(_transformTargetView)
    {
        //해당 컨텐츠를 만든사람이 본인이라서 편집이 가능한경우에만 편집
        if([[_transformTargetView getUserIdx] compare:[UserInfo getUserIdx]] == NSOrderedSame)
        {
            _transformTargetView.layer.borderWidth = BORDER;
            _transformTargetView.layer.borderColor = [UIColor orangeColor].CGColor;
            self.freeTransformGestureRecognizer.enabled = TRUE;
            self.dockController.panGestureRecognizer.enabled = FALSE;
            self.contentsContainer.scrollEnabled = NO;
        }
        else{
            
        }
    }
    else {
        self.freeTransformGestureRecognizer.enabled = FALSE;
        self.dockController.panGestureRecognizer.enabled = TRUE;
        self.contentsContainer.scrollEnabled = YES;
    }
}

#pragma mark 컨텐츠를 롱탭하면 트랜스폼 타겟뷰로 걸리게 하는 제스쳐를 추가하는 부분과 콜백
-(void) onLongPressContent : (UILongPressGestureRecognizer*) gestureRecognizer{
 //   [UEUI ziggleAnimation:gestureRecognizer.view];
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        NSLog(@"Long PressContent : %@",gestureRecognizer);
        if(gestureRecognizer.view == self.transformTargetView){
            [self setTransformTargetView:NULL];
        }
        else{
            [self setTransformTargetView:gestureRecognizer.view];
        }
    }
}
-(void) addTransformTargetGestureToEntityView : (UIView*) view{
    view.userInteractionEnabled = TRUE;
    UILongPressGestureRecognizer* longTapGestureRecognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self
                                                                                                          action:@selector(onLongPressContent:)];
    [view addGestureRecognizer:longTapGestureRecognizer];
    longTapGestureRecognizer.delegate = self;
    NSLog(@"%@",longTapGestureRecognizer);
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
                                                                               withUser : [UserInfo getUserIdx].stringValue];
        [request setCompletionBlock:^{
            NSLog(@"%@",request.responseString);
        }];
        [request setFailedBlock:^{
            NSLog(@"fail : ");
        }];
        [request startAsynchronous];
    }
}

-(SoundContentView*) onCreateSound : (NSString*) file{
    
    SoundContent* soundEntity = (SoundContent*)[[UECoreData sharedInstance]insertNewObject:@"SoundContent"];
    soundEntity.idx       = NULL;
    soundEntity.paper_idx = self.entity.idx;
    soundEntity.user_idx  = [NSNumber numberWithInt:[UserInfo getUserIdx].intValue];
    soundEntity.x         = [NSNumber numberWithFloat:self.view.frame.size.width /2];
    soundEntity.y         = [NSNumber numberWithFloat:self.view.frame.size.height/2];
    soundEntity.width     = [NSNumber numberWithFloat:SOUND_CONTENT_WIDTH];
    soundEntity.height    = [NSNumber numberWithFloat:SOUND_CONTENT_HEIGHT];
    soundEntity.sound     = [file mutableCopy];
    
    SoundContentView* entityView = [[SoundContentView alloc] initWithEntity:soundEntity];
    entityView.isNeedToSyncWithServer = TRUE;
    [self.contentsScrollContainer addSubview:entityView];
    [self addTransformTargetGestureToEntityView:entityView];
    
    self.transformTargetView = entityView;
    return entityView;
}
-(ImageContentView*) onCreateImage : (UIImage *)image{
    CGImageRef cgImage = image.CGImage;
    CGFloat width   = CGImageGetWidth(cgImage) / APP_SCALE;
    CGFloat height  = CGImageGetHeight(cgImage) / APP_SCALE;
    
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
    [self.contentsScrollContainer addSubview:entityView];
    [self addTransformTargetGestureToEntityView:entityView];
    
    self.transformTargetView = entityView;
    return entityView;
}
-(BOOL) canBecomeFirstResponder{
    return YES;
}
/*
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    if (event.type    == UIEventTypeMotion &&
        event.subtype == UIEventSubtypeMotionShake) {
        [self.navigationController popViewControllerAnimated:TRUE];
    }
}
 */
- (void)viewDidUnload {
    [self setContentsContainer:nil];
    [super viewDidUnload];
}


-(BOOL) gestureRecognizer : (UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer : (UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == [contentsScrollContainer.gestureRecognizers objectAtIndex:0] ||
        otherGestureRecognizer == [contentsScrollContainer.gestureRecognizers objectAtIndex:0]) {
        return NO;
    }
    return YES;
}

#pragma mark DockControllerDelegate
-(void) dockController:(DockController *)dock
              pickMenu:(DockMenuType)menuType
              inButton:(UIButton *)button{
    NSLog(@"%@ %d %@",dock,menuType,button);
    self.dockController.panGestureRecognizer.enabled = FALSE;
    [dock hide];
    switch (menuType) {
        case DockMenuTypeCamera:{
            /*
            CameraController* camViewController = [[CameraController alloc] initWithDelegate:self];
            [self addChildViewController:camViewController];
            [self.view addSubview:camViewController.view];
             */
            UIImagePickerController* cameraController = [[UIImagePickerController alloc]init];
            cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
            cameraController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
            cameraController.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
            cameraController.allowsEditing = TRUE;
            cameraController.delegate = self;
            
            [self presentViewController:cameraController
                               animated:TRUE
                             completion:^{
                                
                             }];
        }break;
        case DockMenuTypeAlbum:{
            AlbumController* albumController = [[AlbumController alloc]initWithDelegate:self];
            [self addChildViewController:albumController];
            [self.view addSubview:albumController.view];
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
            PencilcaseController* pencilcaseController = [[PencilcaseController alloc]initWithDelegate:self];
            [self addChildViewController:pencilcaseController];
            [self.view addSubview:pencilcaseController.view];
        }break;
        case DockMenuTypeSave : {
            [self.navigationController popViewControllerAnimated:TRUE];
        }break;
        default:
            NSLog(@"Unhandled dock menu %d",menuType);
            break;
    }
}
#pragma mark CameraControllerDelegate 
/*
-(void) cameraController:(CameraController *)camera
             onPickImage:(UIImage *)image{
    if(image){
        //이미지를 선택한경우
        [self onCreateImage:image];
    }
    [camera removeFromParentViewController];
    [camera.view removeFromSuperview];
}
-(void) cameraControllerCancelPicking:(CameraController *)camera{
    
}
 */
-(void) imagePickerController : (UIImagePickerController *)picker
didFinishPickingMediaWithInfo : (NSDictionary *)info{
    ImageContentView* contentView = [self onCreateImage:[info objectForKey:UIImagePickerControllerEditedImage]];
    contentView.center = ccpAdd(ccp(self.view.frame.size.width/2 ,
                                    self.view.frame.size.height/2),self.contentsContainer.contentOffset);
    
    [self dismissViewControllerAnimated:TRUE completion:^{
        
    }];
}
-(void) imagePickerControllerDidCancel : (UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:TRUE completion:^{
        
    }];
}
#pragma mark AlbumControllerDelegate
-(void) albumController:(AlbumController *)albumController
              pickImage:(UIImage *)image
               withInfo:(NSDictionary *)infodict{
    ImageContentView* contentView = [self onCreateImage:image];
    contentView.center = ccpAdd(ccp(self.view.frame.size.width/2 ,
                                    self.view.frame.size.height/2),self.contentsContainer.contentOffset);
    
    [albumController removeFromParentViewController];
    [albumController.view removeFromSuperview];
}
-(void) albumControllerCancelPickingImage:(AlbumController *)albumController{
    [albumController removeFromParentViewController];
    [albumController.view removeFromSuperview];
}
#pragma mark TypewriterControllerDelegate
-(void) typewriterController:(TypewriterController *)typewriterController
                endEditImage:(UIImage *)image{
    [self onCreateImage:image];
    [typewriterController removeFromParentViewController];
    [typewriterController.view removeFromSuperview];
}
-(void) typewriterControllerDidCancelTyping:(TypewriterController *)typewriterController{
    [typewriterController removeFromParentViewController];
    [typewriterController.view removeFromSuperview];
}
#pragma mark PencilcaseControllerDelegate
-(void) pencilcaseController:(PencilcaseController *)pencilcaseController
             didEndDrawImage:(UIImage *)image
                      inRect:(CGRect)rect {
    ImageContentView* createdImageView = [self onCreateImage:image];
    [pencilcaseController removeFromParentViewController];
    [pencilcaseController.view removeFromSuperview];
    
    //브러쉬로 그리는 화면은 스크롤 위치가 포함 안되기 때문에 정리
    rect.origin = ccpAdd(rect.origin, self.contentsContainer.contentOffset);
    createdImageView.frame = rect;
}
-(void) pencilcaseControllerdidCancelDraw:(PencilcaseController *)pencilcaseController{
    [pencilcaseController hideBottomDock];
    [pencilcaseController removeFromParentViewController];
    [pencilcaseController.view removeFromSuperview];
}
#pragma mark RecoderControllerDelegate
-(void) recoderViewController : (RecoderController *)recoderController
        onEndRecodingWithFile : (NSString *)file{
    SoundContentView* createdSoundView = [self onCreateSound:file];
    [recoderController removeFromParentViewController];
    [recoderController.view removeFromSuperview];

    NSLog(@"%@",createdSoundView);
    CGRect rect = createdSoundView.frame;
    rect.size   = CGSizeMake(50, 50);
    rect.origin = ccp(480/2, 320/2);
    UIViewSetOrigin(createdSoundView, CGPointMake(self.view.frame.origin.x/2, self.view.frame.origin.y/2));
    //브러쉬로 그리는 화면은 스크롤 위치가 포함 안되기 때문에 정리
    rect.origin = ccpAdd(rect.origin, self.contentsContainer.contentOffset);
    createdSoundView.frame = rect;
    NSLog(@"%@",createdSoundView);
}


/*
     화면을 돌렸을때 프로그램의 모드가 바뀌는것에 관련된 함수들
 */
-(void) onChangeToInspectingMode{
    isEditingMode = FALSE;
    /* 일단 편집 제스쳐가 다 안먹히게 편집 */
    self.freeTransformGestureRecognizer.enabled = FALSE;
    self.dockController.panGestureRecognizer.enabled = FALSE;
    /******************************/
    
    self.contentsContainer.maximumZoomScale = 1.0f;
//    CGSize scrollSize  = self.contentsContainer.frame.size;
    CGSize contentSize = self.contentsContainer.contentSize;

    self.contentsContainer.minimumZoomScale = 1.0/3;
    self.contentsContainer.scrollEnabled = TRUE;
    [self.contentsContainer zoomToRect:CGRectMake(0, 0, contentSize.width, contentSize.height)
                              animated:TRUE];
    
    [[UIApplication sharedApplication] setStatusBarHidden:TRUE
                                            withAnimation:UIStatusBarAnimationFade];
    
    NSLog(@"%f",self.contentsContainer.zoomScale);
}
-(void) onChangeToEditingMode {
    isEditingMode = TRUE;
    self.contentsContainer.scrollEnabled = FALSE;
    self.transformTargetView = NULL;
    [self.contentsContainer resignFirstResponder];
   
    [self.contentsContainer setZoomScale:1.0f animated:TRUE];
    
    //self.contentsContainer.minimumZoomScale =
    //self.contentsContainer.maximumZoomScale = 1.0f;
    
    /*
    self.contentsContainer.maximumZoomScale = 1.0f;
    CGSize scrollSize  = self.contentsContainer.frame.size;
    CGSize contentSize = self.contentsContainer.contentSize;
    self.contentsContainer.scrollEnabled = TRUE;
    [self.contentsContainer zoomToRect:CGRectMake(0, 0, contentSize.width, contentSize.height)
                              animated:TRUE];
    */
    
    
    [[UIApplication sharedApplication] setStatusBarHidden:FALSE
                                            withAnimation:UIStatusBarAnimationFade];
}
-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{}
-(void) willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                         duration:(NSTimeInterval)duration{}
-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration{
    if( UIInterfaceOrientationIsPortrait(self.interfaceOrientation) &&
        UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ){
        NSLog(@"TO Inspecting Mode");
        [self onChangeToInspectingMode];
    }
    else if( UIInterfaceOrientationIsLandscape(self.interfaceOrientation) &&
             UIInterfaceOrientationIsPortrait(toInterfaceOrientation)){
        NSLog(@"TO Editing Mode");
        [self onChangeToEditingMode];
    }
    else
        NSLog(@"%d %d",self.interfaceOrientation,toInterfaceOrientation);
    
}
-(BOOL) shouldAutorotate{
    return YES;
}
-(NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark UIScrollViewDelegate
-(void)scrollViewDidZoom:(UIScrollView *)scrollView{}
-(void) scrollViewDidEndZooming:(UIScrollView *)scrollView
                       withView:(UIView *)view  
                        atScale:(float)scale{
    if(isEditingMode){
        [scrollView setZoomScale:1.0f animated:TRUE];
    }
}
-(UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.contentsScrollContainer;
}



@end


