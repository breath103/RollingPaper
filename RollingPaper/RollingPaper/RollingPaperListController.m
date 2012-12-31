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
-(void) viewWillAppear:(BOOL)animated{
    // 기존의 컨트롤러들 전부 삭제
    for(PaperCellController* controller in paperCellControllers){
        [controller.view removeFromSuperview];
        [controller removeFromParentViewController];
    }
    [paperCellControllers removeAllObjects];
    
    ASIFormDataRequest* request = [NetworkTemplate requestForRollingPaperListWithUserIdx:[UserInfo getUserIdx].stringValue];
    [request setCompletionBlock:^{
        [self performBlockInMainThread:^{
            SBJSON* parser = [[SBJSON alloc]init];
            NSArray* paperArray = [parser objectWithString:request.responseString];
            int topBorder    = 21;
            int heightMargin = 13;
            int index        = 0;
            
            float cellContainerWidth = self.paperScrollView.frame.size.width;
            for(NSDictionary* p in paperArray){
                RollingPaper* entity = NULL;
                entity = (RollingPaper*)[[UECoreData sharedInstance] insertNewObject : @"RollingPaper"
                                                                            initWith : p];
                NSLog(@"%@",entity);
                /*
                NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
                NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"RollingPaper"
                                                              inManagedObjectContext:[UECoreData sharedInstance].managedObjectContext];
                [fetchRequest setEntity:entityDesc];
                //해당 방이 이미 로딩된적이 있는지 확인
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"idx = %@",[p objectForKey:@"idx"]]];
                NSMutableArray *resultEntity = [[[UECoreData sharedInstance].managedObjectContext executeFetchRequest:fetchRequest
                                                                                                           error:NULL] mutableCopy];
                if( !resultEntity  ||  resultEntity.count <= 0){ //검색결과가 없다, 즉 로딩된적이 없다
                    
                    NSLog(@"새로 생성 %@ : %@",p,entity);
                }
                else {
                    entity = [resultEntity objectAtIndex:0];
                    NSLog(@"이미 있던 방 : %@",entity);
                }
                 */
                if([entity.is_sended compare:@"NONE"] == NSOrderedSame)
                {
                    PaperCellController* cellController = [[PaperCellController alloc] initWithEntity : entity
                                                                                             delegate : self];
                    float viewHeight = cellController.view.frame.size.height;
                    float viewWidth  = cellController.view.frame.size.width;
                    UIViewSetOrigin(cellController.view, CGPointMake(cellContainerWidth/2 - viewWidth/2,topBorder +  (heightMargin + viewHeight) * index++));
                    
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
        } waitUntilDone:TRUE];
    }];
    [request startAsynchronous];
    
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
        profileImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[userDict objectForKey:@"picture"]]]];;
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width/2.0f;
        profileImageView.layer.masksToBounds = TRUE;
        profileImageView.layer.borderWidth = 2.5f;
        profileImageView.layer.borderColor = [UEUI CGColorWithRed:1.0f Green:1.0f Blue:1.0f Alpha:1.0f];
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapUserSetting)];
        [profileImageView addGestureRecognizer:tapGesture];
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
    [self.navigationController pushViewController:paperViewController animated:FALSE];
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
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}
@end
