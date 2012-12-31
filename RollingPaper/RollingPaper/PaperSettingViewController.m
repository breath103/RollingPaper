//
//  PaperSettingViewController.m
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 25..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "PaperSettingViewController.h"

@interface PaperSettingViewController ()

@end

@implementation PaperSettingViewController
@synthesize entity;
-(id) initWithEntity : (RollingPaper*) aEntity{
    self = [self initWithNibName:NSStringFromClass(PaperSettingViewController.class) bundle:NULL];
    if(self){
        self.entity = aEntity;
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
- (void)viewDidLoad
{
    [super viewDidLoad];
    if(self.entity){
        NSLog(@"%@",self.entity);
    }
    // Do any additional setup after loading the view from its nib.
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
