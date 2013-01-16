//
//  PaperSettingController.m
//  RollingPaper
//
//  Created by 이상현 on 13. 1. 15..
//  Copyright (c) 2013년 상현 이. All rights reserved.
//

#import "PaperSettingController.h"

@interface PaperSettingController ()

@end

@implementation PaperSettingController
@synthesize entity;
-(id) initWithPaper : (RollingPaper*) aEntity{
    self = [self initWithNibName:NSStringFromClass(self.class)
                          bundle:NULL];
    self.entity = aEntity;
    if(self){
        if(self.entity){
            
        }
        else{
            NSAssert(self.entity, @"Paper Entity Can not be NULL");
        }
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) syncViewToEntity{
    
}
-(void) syncEntityToView{
    self.titleText.text = self.entity.title;
    self.receiveTime.text = self.entity.receive_time;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self syncEntityToView];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
