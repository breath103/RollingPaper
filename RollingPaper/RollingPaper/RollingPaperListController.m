//
//  RollingPaperListController.m
//  RollingPaper
//
//  Created by 이상현 on 12. 11. 18..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "RollingPaperListController.h"
#import "FlowithAgent.h"
#import "BlockSupport/NSObject+block.h"
#import "RollingPaper.h"
#import "UECoreData.h"
#import "PaperViewController.h"
#import "RollingPaperCreator.h"
#import "macro.h"
#import "CGPointExtension.h"
#import <QuartzCore/QuartzCore.h>
#import "UELib/UEUI.h"
#import "UserSettingViewController.h"
#import <JSONKit.h>

static RollingPaperListController* g_instance = NULL;

@interface RollingPaperListController ()

@end

@implementation RollingPaperListController
@synthesize paperScrollView;

+(RollingPaperListController*) getInstance{
    return g_instance;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        paperCellControllers = [NSMutableArray new];
        g_instance = self;
    }
    return self;
}
-(void) removeAllPaperViews{
    for(PaperCellController* controller in paperCellControllers){
        [UIView animateWithDuration:0.3f animations:^{
            controller.view.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [controller.view removeFromSuperview];
        }];
        [controller removeFromParentViewController];
    }
    [paperCellControllers removeAllObjects];
}
-(void) refreshPaperList{
    [[FlowithAgent sharedAgent]getParticipaitingPapers:^(BOOL isCachedResponse,
                                                         NSArray *paperArray) {
        [self createPaperViewsFromArray:paperArray];
    } failure:^(NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"경고"
                                    message:@"서버로부터 페이퍼 리스트를 받아오는데 실패했습니다"
                                   delegate:nil
                          cancelButtonTitle:@"확인"
                          otherButtonTitles:nil] show];
    }];
}
-(NSMutableDictionary*) fetchAllRollingPaperWithIdxKey{
    NSManagedObjectContext* managedObjectContext = [UECoreData sharedInstance].managedObjectContext;
    NSFetchRequest* fetchRequest = [NSFetchRequest new];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"RollingPaper"
                                                  inManagedObjectContext:[UECoreData sharedInstance].managedObjectContext];
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
        else{
            [entity setValuesWithDictionary:p];
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
            self.paperScrollView.contentSize = CGSizeMake(self.paperScrollView.frame.size.width,
                                                          topBorder + (heightMargin + viewHeight) * index);
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
    NSLog(@"%@",self.navigationController.viewControllers);
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if([[FlowithAgent sharedAgent] getUserInfo]){
        [[FlowithAgent sharedAgent] getProfileImage:^(BOOL isCachedResponse, UIImage *image) {
            [self.profileButton setImage:image forState:UIControlStateNormal];
            [self.profileButton hideToTransparent];
            [self.profileButton fadeIn:0.3f];
        }];
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

-(void) PaperCellTouched : (PaperCellController *) paper
{
    PaperViewController* paperViewController = [[PaperViewController alloc] initWithEntity:paper.entity];
    [self.navigationController pushViewController:paperViewController animated:TRUE];
}
-(void) paperCellSettingTouched:(PaperCellController *)paper{
    RollingPaperCreator* paperSettingView = [[RollingPaperCreator alloc] initForEditing:paper.entity];
    paperSettingView.listController = self;
    [self.navigationController pushViewController : paperSettingView
                                         animated : TRUE];
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
    RollingPaperCreator* controller = [[RollingPaperCreator alloc]initForCreating];
    controller.listController = self;
    [self.navigationController pushViewController:controller
                                         animated:TRUE];
}

- (IBAction)onTouchRefresh:(id)sender {
    [self refreshPaperList];
}

- (IBAction)onTouchProfile:(id)sender {
    UserSettingViewController* settingViewController = [[UserSettingViewController alloc] initWithDefaultNib];
    [self.navigationController pushViewController:settingViewController
                                         animated:TRUE];
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
-(BOOL) showPaperWithIdx : (NSNumber*) paper_idx{
    for(PaperCellController* cellController in self.childViewControllers){
        if(cellController &&
           cellController.entity &&
           [cellController.entity.idx compare:paper_idx] == NSOrderedSame){
            [self PaperCellTouched:cellController];
            return TRUE;
        }
    }
    return FALSE;
}
@end
