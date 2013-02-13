//
//  PaperViewController.m
//  RollingPaper
//
//  Created by 이상현 on 12. 11. 18..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "PaperViewController.h"
#import "ImageContent.h"
#import "SoundContent.h"
#import "UECoreData.h"
#import "UELib/UEImageLibrary.h"
#import "ImageContentView.h"
#import "SoundContentView.h"
#import "FlowithAgent.h"
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
#import <JSONKit.h>
#import "UECoreData.h"


#define BORDER_WIDTH (2.0f)
#define BORDER_COLOR [UIColor colorWithPatternImage:[UIImage imageNamed:@"content_selectborder.png"]]


@interface PaperViewController ()
@end

@implementation PaperViewController
//@synthesize contentsViews;
@synthesize entity;
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
        self.contentsScrollContainer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageWithData:backgroundData]];
    }
    else{
        [[FlowithAgent sharedAgent] getBackground:entity.background
                                         response:^(BOOL isCachedResponse, UIImage *image) {
            self.contentsScrollContainer.backgroundColor = [UIColor colorWithPatternImage:image];
            [self.contentsScrollContainer setNeedsDisplay];
        }];
    }
    ///
    
    self.contentsScrollContainer.userInteractionEnabled = TRUE;
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                                action:@selector(onTapScrollBack:)];

    [self.contentsScrollContainer addGestureRecognizer:tapGesture];

    [self.contentsContainer addSubview:self.contentsScrollContainer];
    
    self.contentsContainer.scrollEnabled = FALSE;
    self.contentsContainer.delegate = self;
}
-(void) onReceiveContentsResponse : (NSArray*) imageContents : (NSArray*) soundContents{
    
    for(UIView* subView in self.contentsScrollContainer.subviews){
        [UIView animateWithDuration:0.2f animations:^{
            subView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [subView removeFromSuperview];
        }];
    }
    
    for(ImageContent* image in imageContents){
        ImageContentView* entityView = [[ImageContentView alloc] initWithEntity:image];
        [self.contentsScrollContainer addSubview:entityView];
    }
    
    for(SoundContent* sound in soundContents){
        SoundContentView* entityView = [[SoundContentView alloc] initWithEntity:sound];
        [self.contentsScrollContainer addSubview:entityView];
    }
    
    [self addTransformTargetGestureToEntityView:[self.contentsScrollContainer.subviews lastObject]];
    
    // 일단 받았음으로 받은 것을 현재 디바이스에 저장한다
}
-(void)loadAndShowContents{
    [[FlowithAgent sharedAgent] getContentsOfPaper:self.entity
                                         afterTime:1
     success:^(BOOL isCachedResponse, NSArray *imageContents,
                                      NSArray *soundContents) {
         NSLog(@"%@ %@",imageContents,soundContents);
         [self onReceiveContentsResponse:imageContents
                                        :soundContents ];
         
     }failure:^(NSError *error) {
         [[[UIAlertView alloc] initWithTitle:@"에러"
                                     message:@"페이퍼 내용을 서버로 부터 받아오는 실패했습니다. 다시 시도해주세요"
                                    delegate:nil
                           cancelButtonTitle:@"확인"
                           otherButtonTitles: nil] show];
     }];
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
- (IBAction)onTouchRefresh:(id)sender {
    [self saveToServer];
    
    self.contentsContainer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"main_background"]];
    [self loadAndShowContents];
    
    self.transformTargetView = NULL;
}


-(void) onTapScrollBack : (UITapGestureRecognizer*) tap{
    if(tap.state == UIGestureRecognizerStateBegan){
        self.transformTargetView = NULL;
        NSLog(@"Long Background : %@",tap);
    }
}
-(void) saveToServer{
    int i = 0;
    for( id<RollingPaperContentViewProtocol> view in self.contentsViews){
        if([view isNeedToSyncWithServer]){
            [view syncEntityWithServer];
            i++;
        }
    }
    NSLog(@"%d개 업데이트 되었습니다",i);
}
-(void) viewWillDisappear:(BOOL)animated{
    [self saveToServer];
}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}
- (void) viewWillAppear:(BOOL)animated{
    NSLog(@"%@",self.view);
    UIViewSetHeight(self.dockController.view, self.view.bounds.size.height);
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
-(void) onTouchContentDeleteButton : (UITapGestureRecognizer*) recognizer{
    UIButton* deleteButton = recognizer.view;
    [[deleteButton superview] fadeOut:0.2f];
    [deleteButton removeFromSuperview];
    [self setTransformTargetView:NULL];
}
-(void) setTransformTargetView:(UIView<RollingPaperContentViewProtocol> *)aTransformTargetView{
    if(_transformTargetView){
        _transformTargetView.layer.borderWidth = 0.0f;
        [[_transformTargetView viewWithTag:6666] removeFromSuperview];
    }
    
    _transformTargetView = aTransformTargetView;
    if(_transformTargetView)
    {
        //해당 컨텐츠를 만든사람이 본인이라서 편집이 가능한경우에만 편집
        if([[_transformTargetView getUserIdx] compare:[[FlowithAgent sharedAgent] getUserIdx]] == NSOrderedSame)
        {
            _transformTargetView.layer.borderWidth = BORDER_WIDTH;
            _transformTargetView.layer.borderColor = BORDER_COLOR.CGColor;
            self.freeTransformGestureRecognizer.enabled = TRUE;
            self.dockController.panGestureRecognizer.enabled = FALSE;
            self.contentsContainer.scrollEnabled = NO;
            
            UIButton* deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
            deleteButton.tag = 6666;
            [deleteButton setImage:[UIImage imageNamed:@"content_delete_button"] forState:UIControlStateNormal];
            /*
            [deleteButton addTarget : self
                             action : @selector(onTouchContentDeleteButton:)
                   forControlEvents : UIControlEventTouchUpInside];
             */
            UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchContentDeleteButton:)];
            [deleteButton addGestureRecognizer:tapGesture];
            
            deleteButton.frame = CGRectMake(0, 0,50,50);
            deleteButton.center = CGPointMake(_transformTargetView.bounds.size.width, 0);
            deleteButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            
            [_transformTargetView addSubview:deleteButton];
            [_transformTargetView bringSubviewToFront:deleteButton];
            
            _transformTargetView.userInteractionEnabled = TRUE;
            NSLog(@"%@",_transformTargetView);
            NSLog(@"%@",deleteButton);
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

-(SoundContentView*) onCreateSound : (NSString*) file{
    
    SoundContent* soundEntity = (SoundContent*)[[UECoreData sharedInstance]insertNewObject:@"SoundContent"];
    soundEntity.idx       = NULL;
    soundEntity.paper_idx = self.entity.idx;
    soundEntity.user_idx  = [NSNumber numberWithInt:[[FlowithAgent sharedAgent] getUserIdx].intValue];
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
    imageEntity.user_idx  = [NSNumber numberWithInt:[[FlowithAgent sharedAgent] getUserIdx].intValue];
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
    [dock hideIndicator];
    
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
            
            self.currentEditingViewController = cameraController;
        }break;
        case DockMenuTypeAlbum:{
            AlbumController* albumController = [[AlbumController alloc]initWithDelegate:self];
            [self addChildViewController:albumController];
            [self.view addSubview:albumController.view];
            UIViewSetHeight(albumController.view, self.view.frame.size.height);
            [albumController.view layoutSubviews];
            
            self.currentEditingViewController = albumController;
        }break;
        case DockMenuTypeKeyboard : {
            TypewriterController* typewriterController = [[TypewriterController alloc]initWithDelegate:self];
            [self addChildViewController:typewriterController];
            [self.view addSubview:typewriterController.view];
            UIViewSetHeight(typewriterController.view, self.view.frame.size.height);
            [typewriterController.view layoutSubviews];
            
            UIViewSetY(typewriterController.view, self.view.frame.size.height);
            [UIView animateWithDuration:0.3f animations:^{
                UIViewSetY(typewriterController.view, 0);
            } completion:^(BOOL finished) {
                
            }];
            
            self.currentEditingViewController = typewriterController;
        }break;
        case DockMenuTypeMicrophone: {
            RecoderController* recoderController = [[RecoderController alloc] initWithDelegate:self];
            [self addChildViewController:recoderController];
            [self.view addSubview:recoderController.view];
            UIViewSetHeight(recoderController.view, self.view.frame.size.height);
            [recoderController.view layoutSubviews];
            
            recoderController.view.alpha = 0.0f;
            [UIView animateWithDuration:0.4f animations:^{
                recoderController.view.alpha = 1.0f;
            }];
            
            self.currentEditingViewController = recoderController;
        }break;
        case DockMenuTypePencilcase: {
            PencilcaseController* pencilcaseController = [[PencilcaseController alloc]initWithDelegate:self];
            [self addChildViewController:pencilcaseController];
            [self.view addSubview:pencilcaseController.view];
            UIViewSetHeight(pencilcaseController.view, self.view.frame.size.height);
            [pencilcaseController.view layoutSubviews];
            
            self.currentEditingViewController = pencilcaseController;
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

-(void) onEditingViewDismissed{
    [dockController showIndicator];
    self.currentEditingViewController = NULL;
}
-(void) imagePickerController : (UIImagePickerController *)picker
didFinishPickingMediaWithInfo : (NSDictionary *)info{
    ImageContentView* contentView = [self onCreateImage:[info objectForKey:UIImagePickerControllerEditedImage]];
    contentView.center = ccpAdd(ccp(self.view.frame.size.width/2 ,
                                    self.view.frame.size.height/2),self.contentsContainer.contentOffset);
    
    [self dismissViewControllerAnimated:TRUE completion:^{
        
    }];
    [self onEditingViewDismissed];
}
-(void) imagePickerControllerDidCancel : (UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:TRUE completion:^{
        
    }];
    
    [self onEditingViewDismissed];
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
    
    [self onEditingViewDismissed];
}
-(void) albumControllerCancelPickingImage:(AlbumController *)albumController{
    [albumController removeFromParentViewController];
    [albumController.view removeFromSuperview];
    
    
    [self onEditingViewDismissed];
}
#pragma mark TypewriterControllerDelegate
-(void) typewriterController:(TypewriterController *)typewriterController
                endEditImage:(UIImage *)image{
    ImageContentView* createdImageView = [self onCreateImage:image];
    
    [typewriterController removeFromParentViewController];
    [typewriterController.view removeFromSuperview];
    
    createdImageView.center = ccpAdd(ccp(self.view.frame.size.width/2,self.view.frame.size.height/2),self.contentsContainer.contentOffset);
    
    [self onEditingViewDismissed];
}
-(void) typewriterControllerDidCancelTyping:(TypewriterController *)typewriterController{
    [typewriterController removeFromParentViewController];
    [typewriterController.view removeFromSuperview];
    
    
    [self onEditingViewDismissed];
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
    
    [self onEditingViewDismissed];
}
-(void) pencilcaseControllerdidCancelDraw:(PencilcaseController *)pencilcaseController{
    [pencilcaseController hideBottomDock];
    [pencilcaseController removeFromParentViewController];
    [pencilcaseController.view removeFromSuperview];
    
    [self onEditingViewDismissed];
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
    
    
    [self onEditingViewDismissed];
}
-(void) recoderViewControllerCancelRecoding:(RecoderController *)recoder
{
    [UIView animateWithDuration:0.2f
                     animations:^{
                         recoder.view.alpha = 0.0f;
                     }completion:^(BOOL finished) {
                         [recoder.view removeFromSuperview];
                         [recoder removeFromParentViewController];
                     }];
    
    [self onEditingViewDismissed];
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
    
    [self.dockController hide];
    [self.dockController hideIndicator];
    
    self.contentsContainer.maximumZoomScale = 1.0f;
//  CGSize scrollSize  = self.contentsContainer.frame.size;
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
    self.contentsContainer.minimumZoomScale = 1.0f;
    self.contentsContainer.maximumZoomScale = 1.0f;
   
   // [self.dockController show];
    [self.dockController showIndicator];
    
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
    if(self.currentEditingViewController){
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    else
        return UIInterfaceOrientationMaskAll;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark UIScrollViewDelegate

//인스펙팅 모드로 넘어갔을때 아이폰 5등에서도 무조건 컨텐츠들이 스크롤뷰 중앙으로몰리게 
-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    
     
}
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


