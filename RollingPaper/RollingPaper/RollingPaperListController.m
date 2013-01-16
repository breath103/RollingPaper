//
//  RollingPaperListController.m
//  RollingPaper
//
//  Created by 이상현 on 12. 11. 18..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "RollingPaperListController.h"
#import "NetworkTemplate.h"
#import "UserInfo.h"
#import "BlockSupport/NSObject+block.h"
#import "SBJSON/SBJSON.h"
#import "RollingPaper.h"
#import "UECoreData.h"
#import "PaperViewController.h"
#import "RollingPaperCreator.h"
#import "macro.h"
#import "CGPointExtension.h"
#import <QuartzCore/QuartzCore.h>
#import "UELib/UEUI.h"
#import "UserSettingViewController.h"

@interface RollingPaperListController ()

@end

@implementation RollingPaperListController
@synthesize paperScrollView;
@synthesize profileImageView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        paperCellControllers = [NSMutableArray new];
    }
    return self;
}
-(void) removeAllPaperViews{
    for(PaperCellController* controller in paperCellControllers){
        [controller.view removeFromSuperview];
        [controller removeFromParentViewController];
    }
    [paperCellControllers removeAllObjects];
}
-(void) refreshPaperList{
    ASIFormDataRequest* request = [NetworkTemplate requestForRollingPaperListWithUserIdx:[UserInfo getUserIdx].stringValue];
    [request setCompletionBlock:^{
        [self performBlockInMainThread:^{
            SBJSON* parser = [[SBJSON alloc]init];
            NSArray* paperArray = [parser objectWithString:request.responseString];
            [self createPaperViewsFromArray:paperArray];
        } waitUntilDone:TRUE];
    }];
    [request setFailedBlock:^{
        [[[UIAlertView alloc] initWithTitle : @"Error"
                                    message : @"서버로부터 롤링페이퍼 리스트를 받아오지 못했습니다"
                                   delegate : nil
                          cancelButtonTitle : @"OK"
                          otherButtonTitles : nil] show];
    }];
    [request startAsynchronous];
}
-(NSMutableDictionary*) fetchAllRollingPaperWithIdxKey{
    NSManagedObjectContext* managedObjectContext = [UECoreData sharedInstance].managedObjectContext;
    NSFetchRequest* fetchRequest = [NSFetchRequest new];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"RollingPaper" inManagedObjectContext:[UECoreData sharedInstance].managedObjectContext];
    [fetchRequest setEntity:entityDesc];
    
    NSMutableArray *entities = [[managedObjectContext executeFetchRequest:fetchRequest error:NULL] mutableCopy];
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
    for(RollingPaper* rollingPaper in entities){
        [dict setObject:rollingPaper forKey:rollingPaper.idx];
    }
    return dict;
}
-(void) createPaperViewsFromArray : (NSArray*) paperDictArray{
    int topBorder    = 21;
    int heightMargin = 13;
    int index        = 0;
    
    float cellContainerWidth = self.paperScrollView.frame.size.width;
    
    [self removeAllPaperViews];
    
    NSMutableDictionary* storedPapers = [self fetchAllRollingPaperWithIdxKey];
    for(NSDictionary* p in paperDictArray){
        RollingPaper* entity = NULL;
        
        entity = [storedPapers objectForKey:[p objectForKey:@"idx"]];
        NSLog(@"%@",entity);
        
        if( ! entity ){
            entity = (RollingPaper*)[[UECoreData sharedInstance] insertNewObject : @"RollingPaper"
                                                                        initWith : p];
            entity.is_new = [NSNumber numberWithBool:YES];
            NSLog(@"%@",entity);
        }
        
        if([entity.is_sended compare:@"NONE"] == NSOrderedSame)
        {
            PaperCellController* cellController = [[PaperCellController alloc] initWithEntity : entity
                                                                                     delegate : self];
            float viewHeight = cellController.view.frame.size.height;
            float viewWidth  = cellController.view.frame.size.width;
            UIViewSetOrigin(cellController.view, CGPointMake(cellContainerWidth/2 - viewWidth/2,
                                                             topBorder +  (heightMargin + viewHeight) * index++));
            [paperCellControllers addObject:cellController];
            
            [self addChildViewController:cellController];
            [self.paperScrollView addSubview:cellController.view];
            
            CGSize contentSize = self.paperScrollView.contentSize;
            contentSize.height = topBorder + (heightMargin + viewHeight)*index;
            self.paperScrollView.contentSize = contentSize;
        }
        else if ([entity.is_sended compare:@"SENDED"] == NSOrderedSame){
            NSLog(@"SENDED : %@",entity.idx);
        }
    }
    
    [[[UECoreData sharedInstance] managedObjectContext] save:NULL];
}
-(void) viewWillAppear:(BOOL)animated{
    
}
-(void) viewDidAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = TRUE;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if([UserInfo getUserInfo]){
        NSDictionary* userDict = [UserInfo getUserInfo];        
        profileImageView.image = [UserInfo getImageFromPictrueURL];
        
        /*
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2.0f;
        profileImageView.layer.masksToBounds = TRUE;
        profileImageView.layer.borderWidth = 2.5f;
        profileImageView.layer.borderColor = [UEUI CGColorWithRed:1.0f Green:1.0f Blue:1.0f Alpha:1.0f];
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapUserSetting)];
        [profileImageView addGestureRecognizer:tapGesture];
         */
       
        [self refreshPaperList];
    }
    else{
        //이미 로그인 된것이 확인되서 들어왔는데 유저 정보가 없다고 뜨는 크리티컬한 에러
        [[[UIAlertView alloc] initWithTitle:@"error"
                                   message:@"유저 정보를 확인할 수 없습니다"
                                  delegate:NULL
                         cancelButtonTitle:NULL
                         otherButtonTitles:@"확인", nil] show];
        
        [self.navigationController popViewControllerAnimated:TRUE];
    }
}
-(void) onTapUserSetting{
    UserSettingViewController* settingViewController = [[UserSettingViewController alloc] initWithNibName:NSStringFromClass(UserSettingViewController.class)
                                                                                                   bundle:NULL];
    [self.navigationController pushViewController:settingViewController
                                         animated:TRUE];
}
-(void) PaperCellTouched : (PaperCellController *) paper
{
    PaperViewController* paperViewController = [[PaperViewController alloc] initWithEntity:paper.entity];
    [self.navigationController pushViewController:paperViewController animated:TRUE];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [self setPaperScrollView:nil];
    [super viewDidUnload];
}

- (IBAction)onTouchAddPaper:(id)sender {
    RollingPaperCreator* controller = [[RollingPaperCreator alloc]initWithNibName:@"RollingPaperCreator" bundle:NULL];
    [self.navigationController pushViewController:controller animated:TRUE];
}


-(BOOL)shouldAutorotate
{
    return YES;
}
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;// | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}
@end
