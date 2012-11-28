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

@interface RollingPaperListController ()

@end

@implementation RollingPaperListController
@synthesize paperScrollView;
@synthesize rollingPapers;
@synthesize profileImage;
@synthesize profileImageView;
@synthesize paperCellControllers;
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
    // Do any additional setup after loading the view from its nib.
    ASIFormDataRequest* request = [NetworkTemplate requestForRollingPaperListWithUserIdx:[UserInfo getUserIdx]];
    for(PaperCellController* controller in paperCellControllers){
        [controller.view removeFromSuperview];
        [controller removeFromParentViewController];
    }
    paperCellControllers = [NSMutableArray new];
    
    [request setCompletionBlock:^{
        NSLog(@"%@",request.responseString);
        
        
        //  [self performBlockInMainThread:^{
        SBJSON* parser = [[SBJSON alloc]init];
        NSArray* paperArray = [parser objectWithString:request.responseString];
        int topBorder = 21;
        int heightMargin = 13;
        int index      = 0;
        
        float cellContainerWidth = self.paperScrollView.frame.size.width;
        for(NSDictionary* p in paperArray){
            //  NSLog(@"%@",p);
            RollingPaper* entity = (RollingPaper*)[[UECoreData sharedInstance] insertNewObject:@"RollingPaper"
                                                                                      initWith:p];
            [self.rollingPapers addObject:entity];
            NSLog(@"%@",entity);
            PaperCellController* cellController = [[PaperCellController alloc] initWithEntity:entity
                                                                                     delegate:self];
            float viewHeight = cellController.view.frame.size.height;
            float viewWidth  = cellController.view.frame.size.width;
            UIViewSetOrigin(cellController.view, CGPointMake(cellContainerWidth/2 - viewWidth/2,topBorder +  (heightMargin + viewHeight) * index++));
            
            
            [self.paperCellControllers addObject:cellController];
            [self addChildViewController:cellController];
            [self.paperScrollView addSubview:cellController.view];
            
            CGSize contentSize = self.paperScrollView.contentSize;
            contentSize.height = topBorder + (heightMargin + viewHeight)*index;
            self.paperScrollView.contentSize = contentSize;
        }
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
    rollingPapers = [NSMutableArray new];
    
    if(profileImage){
        profileImageView.image = profileImage;
    }
}
-(void) PaperCellTouched:(PaperCellController *)paper
{
    PaperViewController* paperViewController = [[PaperViewController alloc] initWithEntity:paper.entity];
    [self.navigationController pushViewController:paperViewController animated:TRUE];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setPaperScrollView:nil];
    [super viewDidUnload];
}


- (IBAction)onTouchAddPaper:(id)sender {
    RollingPaperCreator* controller = [[RollingPaperCreator alloc]initWithNibName:@"RollingPaperCreator" bundle:NULL];
    [self.navigationController pushViewController:controller animated:TRUE];
}
@end
