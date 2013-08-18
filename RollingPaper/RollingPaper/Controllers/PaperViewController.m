#import "PaperViewController.h"
#import "ImageContent.h"
#import "SoundContent.h"
#import "UECoreData.h"
#import "ImageContentView.h"
#import "SoundContentView.h"
#import "FlowithAgent.h"
#import "CGPointExtension.h"
#import "ccMacros.h"
#import "RecoderController.h"
#import "AlbumController.h"
#import "PencilcaseController.h"
#import <QuartzCore/QuartzCore.h>
#import "UEFileManager.h"
#import <JSONKit.h>
#import "UECoreData.h"
#import "RollingPaperCreator.h"
#import "UIAlertViewBlockDelegate.h"
#import "UIImageView+Vingle.h"
#import "PaperSettingsViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>

#define BORDER_WIDTH (2.0f)
#define BORDER_COLOR [UIColor colorWithPatternImage:[UIImage imageNamed:@"content_selectborder.png"]]

@interface PaperViewController (PrivateInterface)
-(void) saveToServer : (void(^)(NSMutableArray* syncSuccessedViews,
                                NSMutableArray* syncFailedViews)) callback;
@end


@implementation PaperViewController

- (id)initWithEntity:(RollingPaper *)paper{
    self = [self init];
    if( self) {
        [self setEntity:paper];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initContentsEditingToolControllers];
    [self initLeftDockMenu];
    [self initContentsScrollContainer];

    [self loadAndShowContents];
    
    [[_saveButton superview] bringSubviewToFront:_saveButton];
    [[_refreshButton superview] bringSubviewToFront:_refreshButton];
    [[_settingsButton superview] bringSubviewToFront:_settingsButton];
    
    [self onChangeToEditingMode];
    [self setTransformTargetView:nil];
}


- (void)initContentsEditingToolControllers
{
    _freeTransformGestureRecognizer = [[UIFreeTransformGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(onFreeTransformGesture)];
    [_freeTransformGestureRecognizer setDelegate:_freeTransformGestureRecognizer];
    [_contentsContainer addGestureRecognizer:_freeTransformGestureRecognizer];
}
- (void)initLeftDockMenu {}
- (void)initContentsScrollContainer
{
    _contentsScrollContainer = [[UIView alloc]initWithFrame:[_entity bounds]];

    [[[UIImageView alloc] init]setImageWithURL:[_entity background]
    success:^(BOOL isCached, UIImage *image) {
        [_contentsScrollContainer setBackgroundColor:[UIColor colorWithPatternImage:image]];
        [_contentsScrollContainer setNeedsDisplay];
    } failure:^(NSError *error) {}];
    
    UILongPressGestureRecognizer* backFocus = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(onTapScrollBack:)];
    [backFocus setMinimumPressDuration:0.1f];
    self.backFocusTapGestureRecognizer = (UITapGestureRecognizer*)backFocus;
    [self.contentsContainer addGestureRecognizer:self.backFocusTapGestureRecognizer];
    self.backFocusTapGestureRecognizer.delegate = self;

    [_contentsContainer addSubview:_contentsScrollContainer];
    [_contentsContainer setContentSize:[_contentsScrollContainer frame].size];
    
    self.contentsContainer.scrollEnabled = YES;
    self.contentsContainer.userInteractionEnabled = YES;
    self.contentsContainer.delegate = self;
    self.contentsContainer.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"main_background"]];

}


-(void) onReceiveContentsResponse : (NSArray*) imageContents
                                  : (NSArray*) soundContents{
    
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
        [self addTransformTargetGestureToEntityView:entityView];
        [entityView hideToTransparent];
        [entityView fadeIn:0.1f];
    }
    
    for(SoundContent* sound in soundContents){
        SoundContentView* entityView = [[SoundContentView alloc] initWithEntity:sound];
        [self.contentsScrollContainer addSubview:entityView];
        [self addTransformTargetGestureToEntityView:entityView];
        [entityView hideToTransparent];
        [entityView fadeIn:0.1f];
    }
    // 일단 받았음으로 받은 것을 현재 디바이스에 저장한다
}
-(void)loadAndShowContents
{
    UIView* loadingOverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    loadingOverView.backgroundColor = [UIColor blackColor];
    loadingOverView.alpha = 0.0f;
    activityIndicator.center = loadingOverView.center;
    [loadingOverView addSubview:activityIndicator];
    [[self view] addSubview:loadingOverView];
    [activityIndicator startAnimating];
    [loadingOverView fadeIn:1.0f];
    
    [self.entity getContents:^(NSArray *imageContents, NSArray *soundContents) {
        [loadingOverView fadeOut:0.2f];
        [self onReceiveContentsResponse:imageContents
                                       :soundContents];
    } failure:^(NSError *error) {
        [loadingOverView fadeOut:0.2f];
        [[[UIAlertViewBlock alloc] initWithTitle:@"에러"
                                         message:@"페이퍼 내용을 서버로 부터 받아오는 실패했습니다. 다시 시도해주세요"
                                   blockDelegate:^(UIAlertView *alertView, int clickedButtonIndex) {
                                       if(clickedButtonIndex == 1)
                                           [self loadAndShowContents];
                                   }
                               cancelButtonTitle:@"확인"
                               otherButtonTitles:@"재시도",nil] show];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationController] setNavigationBarHidden:YES
                                               animated:YES];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_contentsContainer setContentSize:[_contentsScrollContainer frame].size];
}

- (void)onTapScrollBack:(UITapGestureRecognizer *)tap
{
    if(tap.state == UIGestureRecognizerStateBegan){
        self.transformTargetView = NULL;
        NSLog(@"Long Background : %@",tap);
    }
}
-(void) saveToServer:(void(^)(NSMutableArray *syncSuccessedViews, NSMutableArray *syncFailedViews)) callback
{
    __block NSMutableArray* syncSuccessedViews = [NSMutableArray new];
    __block NSMutableArray* syncFailedViews    = [NSMutableArray new];
    
    __block int totalNeedsSyncViewCount = 0;
    
    //서버와 동기화 해야하는 뷰의 갯수를 카운트 한다
    for( id<RollingPaperContentViewProtocol> view in self.contentsViews)
        if([view isNeedToSyncWithServer])
            totalNeedsSyncViewCount++;
        
    if(totalNeedsSyncViewCount > 0){
        for( id<RollingPaperContentViewProtocol> view in self.contentsViews){
            if([view isNeedToSyncWithServer]){
                [view syncEntityWithServer:^(NSError *error,
                                             UIView<RollingPaperContentViewProtocol> *view) {
                    if(error){
                        NSLog(@"%@ sync failure",view);
                        [syncFailedViews addObject:view];
                    }
                    else{
                        NSLog(@"%@ sync success",view);
                        [syncSuccessedViews addObject:syncSuccessedViews];
                        if( (syncSuccessedViews.count + syncFailedViews.count) >= totalNeedsSyncViewCount ){
                            callback(syncSuccessedViews,syncFailedViews);
                        }
                    }
                }];
            }
        }
    }
    else {
        callback(syncSuccessedViews,syncFailedViews);
    }
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
        self.transformTargetView.isNeedToSyncWithServer = YES;
    }
}
-(void) onTouchContentDeleteButton : (UITapGestureRecognizer*) recognizer{
    UIButton* deleteButton = (UIButton*)recognizer.view;
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
            self.freeTransformGestureRecognizer.enabled = YES;
//            self.dockController.panGestureRecognizer.enabled = NO;
//            self.contentsContainer.scrollEnabled = NO;
            
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
            
            _transformTargetView.userInteractionEnabled = YES;
            NSLog(@"%@",_transformTargetView);
            NSLog(@"%@",deleteButton);
        }
        else{
            
        }
    }
    else {
        self.freeTransformGestureRecognizer.enabled = NO;
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
            [self setTransformTargetView:(UIView<RollingPaperContentViewProtocol>*)gestureRecognizer.view];
        }
    }
}
-(void) addTransformTargetGestureToEntityView:(UIView *) view
{
    view.userInteractionEnabled = YES;
    UILongPressGestureRecognizer* longTapGestureRecognizer = [[UILongPressGestureRecognizer alloc]
                                                    initWithTarget:self
                                                            action:@selector(onLongPressContent:)];
    [view addGestureRecognizer:longTapGestureRecognizer];
    longTapGestureRecognizer.delegate = self;
}

- (SoundContentView *)onCreateSound:(NSString *)file
{
    SoundContent* soundEntity = [[SoundContent alloc]init];
    soundEntity.id       = NULL;
    soundEntity.paper_id = self.entity.id;
    soundEntity.user_id  = @([[FlowithAgent sharedAgent] getUserIdx].intValue);
    soundEntity.x        = @(self.view.frame.size.width /2);
    soundEntity.y        = @(self.view.frame.size.height/2);
    soundEntity.width    = @(SOUND_CONTENT_WIDTH);
    soundEntity.height   = @(SOUND_CONTENT_HEIGHT);
    soundEntity.sound    = [file mutableCopy];
    
    SoundContentView* entityView = [[SoundContentView alloc] initWithEntity:soundEntity];
    entityView.isNeedToSyncWithServer = YES;
    [self.contentsScrollContainer addSubview:entityView];
    [self addTransformTargetGestureToEntityView:entityView];
    
    self.transformTargetView = entityView;
    return entityView;
}

- (ImageContentView *)onCreateImage:(UIImage *)image
{
    CGImageRef cgImage = image.CGImage;
    CGFloat width   = CGImageGetWidth(cgImage) / APP_SCALE;
    CGFloat height  = CGImageGetHeight(cgImage) / APP_SCALE;
    
    ImageContent* imageEntity = [[ImageContent alloc]init];
    imageEntity.id       = NULL;
    imageEntity.paper_id = self.entity.id;
    imageEntity.user_id  = @([[FlowithAgent sharedAgent] getUserIdx].intValue);
    imageEntity.x        = @(0.0f);
    imageEntity.y        = @(0.0f);
    imageEntity.rotation = @(0.0f);
    imageEntity.image    = nil;
    imageEntity.width    = @(width);
    imageEntity.height   = @(height);
    
    ImageContentView* entityView = [[ImageContentView alloc] initWithEntity:imageEntity];
    entityView.isNeedToSyncWithServer = YES;
    entityView.imageView.image = image;
    [self.contentsScrollContainer addSubview:entityView];
    [self addTransformTargetGestureToEntityView:entityView];
    
    self.transformTargetView = entityView;
    return entityView;
}
- (BOOL)canBecomeFirstResponder{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer : (UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == [_contentsScrollContainer.gestureRecognizers objectAtIndex:0] ||
        otherGestureRecognizer == [_contentsScrollContainer.gestureRecognizers objectAtIndex:0]) {
        return NO;
    }
    if(gestureRecognizer == self.freeTransformGestureRecognizer &&
       otherGestureRecognizer == self.backFocusTapGestureRecognizer ){
        return NO;
    }
    
    return YES;
}

-(void) hideTopNavigationBar{
    [self.saveButton    fadeOut:0.3f];
    [self.refreshButton fadeOut:0.3f];
}
-(void) showTopNavigationBar{
    [self.saveButton    fadeIn:0.3f];
    [self.refreshButton fadeIn:0.3f];
}

- (IBAction)onTouchFB:(id)sender {
//    [entity presentFacebookDialog]
    [FBWebDialogs presentFeedDialogModallyWithSession:[FBSession activeSession]
                                           parameters:@{
     @"name" : [_entity title],
     @"description" : [_entity notice],
     @"link" : [_entity webViewURL],
     @"picture" : @"https://photos-2.dropbox.com/t/0/AAD98gDYQvXuR5ilF9SDE_Gx3CdcRs35e6pAPueuGeB1tA/12/38281474/png/1024x768/3/1373061600/0/2/logo3.png/KCRsKl14p0JGsSEWdGh_5lz2zEWkzXqGmZhPnSXv8co",
     @"to" : [_entity friend_facebook_id]
     }
    handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:@"전송되었습니다!"
                                   delegate:nil
                          cancelButtonTitle:@"확인"
                          otherButtonTitles: nil]show];
        [[self navigationController] popViewControllerAnimated:YES];
    }];
}


#pragma mark DockControllerDelegate
-(void) dockController:(DockController *)dock
              pickMenu:(DockMenuType)menuType
              inButton:(UIButton *)button
{
    if(menuType != DockMenuTypeSetting &&
       menuType != DockMenuTypeCamera){
        [dock hide];
        [dock hideIndicator];
        
        [self hideTopNavigationBar];
    }
    
    switch (menuType) {
        case DockMenuTypeCamera:{
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
                UIImagePickerController* cameraController = [[UIImagePickerController alloc]init];
                cameraController.sourceType = UIImagePickerControllerSourceTypeCamera;
                cameraController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
                cameraController.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
                cameraController.allowsEditing = YES;
                cameraController.delegate = self;
                [self presentViewController:cameraController
                                   animated:YES
                                 completion:^{
                                     
                                 }];
                self.currentEditingViewController = cameraController;
            }
            else{
                [[[UIAlertView alloc] initWithTitle:@"에러"
                                            message:@"디바이스가 카메라를 지원하지 않습니다"
                                           delegate:nil
                                  cancelButtonTitle:@"확인"
                                  otherButtonTitles: nil]show];
            }
        }break;
        case DockMenuTypeAlbum:{
            AlbumController* albumController = [[AlbumController alloc]initWithDelegate:self];
            [self addChildViewController:albumController];
            [self.view addSubview:albumController.view];
            [albumController.view setHeight:[self.view getHeight]];
            [albumController.view layoutSubviews];
            
            self.currentEditingViewController = albumController;
        }break;
        case DockMenuTypeKeyboard : {
            TypewriterController* typewriterController = [[TypewriterController alloc]initWithDelegate:self];
            [self addChildViewController:typewriterController];
            [self.view addSubview:typewriterController.view];
            [typewriterController.view setHeight:self.view.frame.size.height];
            [typewriterController.view layoutSubviews];
            
            [typewriterController.view setTop:self.view.frame.size.height];
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
        case DockMenuTypeSetting : {
            PaperSettingsViewController *settingsViewController = [[PaperSettingsViewController alloc]initWithPaper:[self entity]];
            [[self navigationController] pushViewController:settingsViewController animated:YES];
        }break;
        default:{
            NSLog(@"Unhandled dock menu %d",menuType);
        }break;
    }
}

-(void) onEditingViewDismissed{
//    [dockController showIndicator];
    [self showTopNavigationBar];
    self.currentEditingViewController = NULL;
}


/*
     화면을 돌렸을때 프로그램의 모드가 바뀌는것에 관련된 함수들
 */
-(void) onChangeToInspectingMode{
    _isEditingMode = NO;
   
    /* 일단 편집 제스쳐가 다 안먹히게 편집 */
    self.freeTransformGestureRecognizer.enabled = NO;
//    self.dockController.panGestureRecognizer.enabled = NO;
    /******************************/
    
//    [self.dockController hide];
//    [self.dockController hideIndicator];
    
    self.contentsContainer.maximumZoomScale = 1.0f;
    CGSize contentSize = self.contentsContainer.contentSize;

    self.contentsContainer.minimumZoomScale = 1.0/3;
    self.contentsContainer.scrollEnabled = YES;
    [self.contentsContainer zoomToRect:CGRectMake(0, 0, contentSize.width, contentSize.height)
                              animated:YES];
    [self.contentsContainer becomeFirstResponder];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationFade];
}
-(void) onChangeToEditingMode
{
    _isEditingMode = YES;
    self.contentsContainer.scrollEnabled = YES;
    self.transformTargetView = nil;
    [self.contentsContainer becomeFirstResponder];
   
    [self.contentsContainer setZoomScale:1.0f animated:YES];
    self.contentsContainer.minimumZoomScale = 2.0f;
    self.contentsContainer.maximumZoomScale = 1.0f;
   
    // [self.dockController show];
    // [self.dockController showIndicator];
    
    //self.contentsContainer.minimumZoomScale =
    //self.contentsContainer.maximumZoomScale = 1.0f;
    
    /*
    self.contentsContainer.maximumZoomScale = 1.0f;
    CGSize scrollSize  = self.contentsContainer.frame.size;
    CGSize contentSize = self.contentsContainer.contentSize;
    self.contentsContainer.scrollEnabled = YES;
    [self.contentsContainer zoomToRect:CGRectMake(0, 0, contentSize.width, contentSize.height)
                              animated:YES];
    */
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationFade];
}

#pragma mark IBOutletActions
- (IBAction)onTouchSaveAndQuit:(id)sender
{
    MBProgressHUD* view = [MBProgressHUD showHUDAddedTo:[self view] animated:YES];
    [self saveToServer:^(NSMutableArray *syncSuccessedViews, NSMutableArray *syncFailedViews) {
        [view hide:YES];
        [[self navigationController] popViewControllerAnimated:YES];
    }];
}
- (IBAction)onTouchRefresh:(id)sender
{
    [self saveToServer:^(NSMutableArray *syncSuccessedViews, NSMutableArray *syncFailedViews) {
        self.contentsContainer.backgroundColor =
        [UIColor colorWithPatternImage:[UIImage imageNamed:@"main_background"]];
        [self loadAndShowContents];
        self.transformTargetView = NULL;
    }];
}
- (IBAction)onTouchSettings:(id)sender {
    PaperSettingsViewController *settingsViewController = [[PaperSettingsViewController alloc]initWithPaper:[self entity]];
    [[self navigationController] pushViewController:settingsViewController
                                           animated:YES];
}


#pragma mark UIViewController
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
    if(_isEditingMode){
        [scrollView setZoomScale:1.0f animated:YES];
    }
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.contentsScrollContainer;
}

#pragma mark UIImagePickerControllerDelegate
-(void) imagePickerController : (UIImagePickerController *)picker
didFinishPickingMediaWithInfo : (NSDictionary *)info{
    ImageContentView *contentView = [self onCreateImage:info[UIImagePickerControllerEditedImage]];
    contentView.center = ccpAdd(ccp(self.view.frame.size.width/2 ,
                                    self.view.frame.size.height/2),self.contentsContainer.contentOffset);
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    [self onEditingViewDismissed];
}
-(void) imagePickerControllerDidCancel : (UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    [self onEditingViewDismissed];
}
#pragma mark AlbumControllerDelegate
-(void) albumController:(AlbumController *)albumController
              pickImage:(UIImage *)image
               withInfo:(NSDictionary *)infodict{
    ImageContentView *contentView = [self onCreateImage:image];
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
    CGRect rect = createdSoundView.frame;
    rect.size   = CGSizeMake(50, 50);
    rect.origin = ccp(480/2, 320/2);
    UIViewSetOrigin(createdSoundView, CGPointMake(self.view.frame.origin.x/2, self.view.frame.origin.y/2));
    //브러쉬로 그리는 화면은 스크롤 위치가 포함 안되기 때문에 정리
    rect.origin = ccpAdd(rect.origin, self.contentsContainer.contentOffset);
    createdSoundView.frame = rect;
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

@end


