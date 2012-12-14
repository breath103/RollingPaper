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
@synthesize albumPickerController;
@synthesize photoPickerController;
@synthesize imagePickerController;
@synthesize entity;
@synthesize friendPickerController;
@synthesize recoderViewController;
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
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.recoderViewController = [[RecoderViewController alloc]initWithDelegate:self];
    
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
-(void) onReceiveContentsResponse : (NSDictionary*) categorizedContents{
    NSDictionary* imageContents = [categorizedContents objectForKey:@"image"];
    for(NSDictionary*p in imageContents){
        ImageContent* imageEntity = (ImageContent*)[[UECoreData sharedInstance]insertNewObject:@"ImageContent" initWith:p];
        ImageContentView* entityView = [[ImageContentView alloc] initWithEntity:imageEntity];
        [self.view addSubview:entityView];
        [contentsViews addObject:entityView];
    }
    NSDictionary* textContents  = [categorizedContents objectForKey:@"text"];
    
    
    NSDictionary* soundContents = [categorizedContents objectForKey:@"sound"];
    for(NSDictionary*p in soundContents){
        SoundContent* soundEntity = (SoundContent*)[[UECoreData sharedInstance]insertNewObject:@"SoundContent" initWith:p];
        SoundContentView* entityView = [[SoundContentView alloc] initWithEntity:soundEntity];
        [self.view addSubview:entityView];
        [contentsViews addObject:entityView];
    }
    
    // 일단 받았음으로 받은 것을 현재 디바이스에 저장한다
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)onAddImage:(id)sender {
    self.navigationController.navigationBarHidden = FALSE;
    if(!self.albumPickerController){
        self.albumPickerController = [[AlbumPickerController alloc]initWithDelegate:self];
    }
    if(!self.imagePickerController){
        self.imagePickerController = [UIImagePickerController new];
        self.imagePickerController.delegate = self;
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
    }
    [self presentModalViewController:self.imagePickerController animated:TRUE];
    //    [self.navigationController pushViewController:albumPickerController animated:TRUE];
}

-(void) imagePickerController : (UIImagePickerController *)picker
didFinishPickingMediaWithInfo : (NSDictionary *)info{
    UIImage* image = [info objectForKey: UIImagePickerControllerOriginalImage];
    ImageContentView* entityView = [self createImageContentViewWithImage:image];
    transformTargetView = entityView;
    
    [self dismissViewControllerAnimated:TRUE completion:^{
    }];
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
-(void) albumPickerController:(AlbumPickerController *)albumPickerController
                onSelectAlbum:(AlbumView *)albumView
{
    photoPickerController = [[PhotoPickerController alloc]initWithAlbumAssetGroup:albumView.albumAssetsGroup
                                                                         delegate:self ];
    [self.navigationController pushViewController:photoPickerController animated:TRUE];
}
-(void) photoPickerController:(PhotoPickerController *)photoPickerController
                onSelectPhoto:(PhotoView *)photoView
{
    ImageContentView* entityView = [self createImageContentViewWithImage:[UEImageLibrary imageFromAssetRepresentation:[photoView.photoAssets defaultRepresentation]]];
    
    transformTargetView = entityView;
    self.navigationController.navigationBarHidden = TRUE;
    [self.navigationController popToViewController:self animated:TRUE];
}

-(ImageContentView*) createImageContentViewWithImage: (UIImage*) image{
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
    [self.view addSubview:entityView];
    [self.contentsViews addObject:entityView];
    
   // transformTargetView = entityView;
    return entityView;
}


-(void)touchesBegan:(NSSet *)touches
          withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self.view];
}
-(void)touchesMoved:(NSSet *)touches
          withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    switch ([allTouches count])
    {
        case 1:
        {
            UITouch *touch = [touches anyObject];
            CGPoint currentPoint = [touch locationInView:self.view];
            
            NSNumber* x = (NSNumber *)[transformTargetView valueForKeyPath:@"layer.transform.translation.x"];
            NSNumber* y = (NSNumber *)[transformTargetView valueForKeyPath:@"layer.transform.translation.y"];
            CGPoint delta = ccpSub(currentPoint, lastPoint);
            [transformTargetView setValue:[NSNumber numberWithDouble:x.doubleValue + delta.x] forKeyPath:@"layer.transform.translation.x"];
            [transformTargetView setValue:[NSNumber numberWithDouble:y.doubleValue + delta.y] forKeyPath:@"layer.transform.translation.y"];
            
            lastPoint = currentPoint;
            break;
        }
        case 2:
        {
            UITouch *touch1 = [[[event allTouches] allObjects] objectAtIndex:0];
            UITouch *touch2 = [[[event allTouches] allObjects] objectAtIndex:1];
            
            CGSize scale;
            NSNumber* rotation;
            [UEUI CGAffineTransformWithTouches:touch1
                                   secondTouch:touch2
                                         scale:&scale
                                      rotation:&rotation];
            NSNumber* prevScaleX = [transformTargetView valueForKeyPath:@"layer.transform.scale.x"];
            NSNumber* prevScaleY = [transformTargetView valueForKeyPath:@"layer.transform.scale.y"];
            [transformTargetView setValue:[NSNumber numberWithDouble:prevScaleX.doubleValue * scale.width]  forKeyPath:@"layer.transform.scale.x"];
            [transformTargetView setValue:[NSNumber numberWithDouble:prevScaleY.doubleValue * scale.height] forKeyPath:@"layer.transform.scale.y"];
            
            NSNumber* prevRotation = [transformTargetView valueForKeyPath:@"layer.transform.rotation.z"];
            [transformTargetView setValue:[NSNumber numberWithDouble:prevRotation.doubleValue + rotation.doubleValue] forKeyPath:@"layer.transform.rotation.z"];
            
            break;
        }
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
            NSLog(@"fail : %@",request);
        }];
        [request startAsynchronous];
    }
}
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.type    == UIEventTypeMotion &&
        event.subtype == UIEventSubtypeMotionShake) {
        [self.navigationController popViewControllerAnimated:TRUE];
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
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
-(void) RecoderViewController:(RecoderViewController *)recoder
        onEndRecodingWithFile:(NSString *)file{
    
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
        [self.view addSubview:entityView];
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
@end
