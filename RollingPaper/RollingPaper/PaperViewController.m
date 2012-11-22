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
#import "UECoreData.h"
#import "UELib/UEImageLibrary.h"
#import "ImageContentView.h"
#import "UserInfo.h"
#import "macro.h"
#import "CGPointExtension.h"
#import "ccMacros.h"

@interface PaperViewController ()

@end

@implementation PaperViewController
@synthesize contentsViews;
@synthesize albumPickerController;
@synthesize photoPickerController;
@synthesize entity;
@synthesize friendPickerController;
-(id) initWithEntity : (RollingPaper*) aEntity
{
    self = [self initWithNibName:@"PaperViewController" bundle:NULL];
    if(self){
        self.entity = aEntity;
        contentsViews = [[NSMutableArray alloc]init];
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
    self.view.multipleTouchEnabled = TRUE;
    
    [super viewDidLoad];
    ASIFormDataRequest* request = [NetworkTemplate requestForRollingPaperContents:self.entity.idx.stringValue
                                                                        afterTime:1];
    [request setCompletionBlock:^{
        SBJSON* parser = [[SBJSON alloc]init];
        NSDictionary* categorizedContents = [parser objectWithString:request.responseString];
        NSLog(@"%@",categorizedContents);
        [self performSelectorOnMainThread:@selector(onReceiveContentsResponse:)
                               withObject:categorizedContents
                            waitUntilDone:TRUE];
    }];
    [request setFailedBlock:^{
        NSLog(@"--%@",request.error);
    }];
    [request startAsynchronous];
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
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)onAddImage:(id)sender {
    self.navigationController.navigationBarHidden = FALSE;
    if(!albumPickerController){
        albumPickerController = [[AlbumPickerController alloc]initWithDelegate:self];
    }
    [self.navigationController pushViewController:albumPickerController animated:TRUE];
}

- (IBAction)onTouchInvite:(id)sender {
    if(!friendPickerController){
        friendPickerController = [[FBFriendPickerViewController alloc] init];
        friendPickerController.title = @"Pick Friends";
        friendPickerController.delegate = self;
        
        [friendPickerController loadData];
        [friendPickerController clearSelection];
        [self presentModalViewController:friendPickerController animated:YES];
    }
}
-(void) albumPickerController:(AlbumPickerController *)albumPickerController onSelectAlbum:(AlbumView *)albumView
{
    photoPickerController = [[PhotoPickerController alloc]initWithAlbumAssetGroup:albumView.albumAssetsGroup
                                                                         delegate:self ];
    [self.navigationController pushViewController:photoPickerController animated:TRUE];
}
-(void) photoPickerController:(PhotoPickerController *)photoPickerController onSelectPhoto:(PhotoView *)photoView
{
    UIImage* image = [UEImageLibrary imageFromAssetRepresentation:[photoView.photoAssets defaultRepresentation]];
    CGImageRef cgImage = image.CGImage;
    CGFloat width   = CGImageGetWidth(cgImage);
    CGFloat height  = CGImageGetHeight(cgImage);
    ImageContent* imageEntity = (ImageContent*)[[UECoreData sharedInstance]insertNewObject:@"ImageContent"];
    imageEntity.idx       = NULL;
    imageEntity.paper_idx = self.entity.idx;
    imageEntity.user_idx  = [NSNumber numberWithInt:[UserInfo getUserIdx].intValue];
    imageEntity.x         = [NSNumber numberWithFloat:self.view.frame.size.width/2 ];
    imageEntity.y         = [NSNumber numberWithFloat:self.view.frame.size.height/2];
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
    self.navigationController.navigationBarHidden = TRUE;
    
    [self.navigationController popToViewController:self animated:TRUE];
}



-(CGPoint) centerPointOfTouches : (NSSet*) touches{
    CGPoint centerPoint = CGPointMake(0,0);
    for(UITouch* touch in touches.allObjects){
        centerPoint = CGPointAdd(centerPoint,[touch locationInView:self.view]);
    }
    return CGPointMultiply(centerPoint, 1.0f/touches.allObjects.count);
}
-(float) rotationOfTouches : (NSSet*) touches{
    if(touches.count >= 2){
        NSArray* array = touches.allObjects;
        CGPoint p1 = [(UITouch*)[array objectAtIndex:0] locationInView:self.view];
        CGPoint p2 = [(UITouch*)[array objectAtIndex:1] locationInView:self.view];
        return -ccpToAngle(ccpSub(p1, p2));
    }
    else {
        return 0.0f;
    }
}
CGAffineTransform CGAffineTransformWithTouches(CGAffineTransform oldTransform,
                                               UITouch *firstTouch,
                                               UITouch *secondTouch)
{
    
    CGPoint firstTouchLocation         = [firstTouch locationInView:nil];
    CGPoint firstTouchPreviousLocaion  = [firstTouch previousLocationInView:nil];
    CGPoint secondTouchLocation        = [secondTouch locationInView:nil];
    CGPoint secondTouchPreviousLocaion = [secondTouch previousLocationInView:nil];
    
    CGAffineTransform newTransform;
    
    CGFloat currentDistance  = ccpDistance(firstTouchLocation,secondTouchLocation);
    CGFloat previousDistance = ccpDistance(firstTouchPreviousLocaion,secondTouchPreviousLocaion);
    
    CGFloat distanceRatio = currentDistance / previousDistance;
    
    newTransform = CGAffineTransformScale(oldTransform, distanceRatio, distanceRatio);
    
    
    CGPoint previousDifference = ccpSub(firstTouchPreviousLocaion, secondTouchPreviousLocaion);
    CGFloat xDifferencePrevious = previousDifference.x;
    
    CGFloat previousRotation = acos(xDifferencePrevious / previousDistance);
    if (previousDifference.y < 0) {
        previousRotation *= -1;
    }
    
    CGPoint currentDifference = ccpSub(firstTouchLocation, secondTouchLocation);
    CGFloat xDifferenceCurrent = currentDifference.x;
    
    CGFloat currentRotation = acos(xDifferenceCurrent / currentDistance);
    if (currentDifference.y < 0) {
        currentRotation *= -1;
    }
    
    CGFloat newAngle = currentRotation - previousRotation;
    
    newTransform = CGAffineTransformRotate(newTransform, newAngle);
    return newTransform;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self.view];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    switch ([allTouches count])
    {
        case 1:
        {
            UITouch *touch = [touches anyObject];
            CGPoint currentPoint = [touch locationInView:self.view];
            
            CGAffineTransform transform = transformTargetView.transform;
            transformTargetView.transform = CGAffineTransformMakeRotation(0);
            transformTargetView.center = ccpAdd(transformTargetView.center , ccpSub(currentPoint, lastPoint));
            transformTargetView.transform = transform;
            
            lastPoint = currentPoint;
            break;
        }
        case 2:
        {
            UITouch *touch1 = [[[event allTouches] allObjects] objectAtIndex:0];
            UITouch *touch2 = [[[event allTouches] allObjects] objectAtIndex:1];
            transformTargetView.transform = CGAffineTransformWithTouches(transformTargetView.transform, touch1, touch2);
            NSLog(@"transform : %@",[transformTargetView valueForKeyPath:@"layer.transform"]);
            break;
        }
    }
}
-(void) facebookViewControllerDoneWasPressed:(id)sender{
    NSMutableArray* friendArray = [[NSMutableArray alloc]init];
    for (id<FBGraphUser> user in friendPickerController.selection) {
        [friendArray addObject: [user id]];
    }
    [self dismissModalViewControllerAnimated:TRUE];
    ASIFormDataRequest* request =  [NetworkTemplate requestForInviteFacebookFriends:friendArray
                                                                            ToPaper:[NSString stringWithFormat:@"%d",self.entity.idx.intValue]
                                                                          withUser:[UserInfo getUserIdx]];
    [request setCompletionBlock:^{
        NSLog(@"%@",request.responseString);
    }];
    [request setFailedBlock:^{
        NSLog(@"fail : %@",request);
    }];
    [request startAsynchronous];
}
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeMotion && event.subtype == UIEventSubtypeMotionShake) {
        [self.navigationController popViewControllerAnimated:TRUE];
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

@end
