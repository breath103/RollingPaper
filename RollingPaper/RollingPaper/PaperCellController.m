//
//  PaperCellController.m
//  RollingPaper
//
//  Created by 이상현 on 12. 11. 23..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "PaperCellController.h"

@interface PaperCellController ()

@end

@implementation PaperCellController
@synthesize entity;
@synthesize delegate;
@synthesize ddayLabel;
@synthesize titleLabel;
-(id) initWithEntity : (RollingPaper*) aEntity
            delegate : (id<PaperCellDelegate>) aDelegate{
    self = [self initWithNibName:@"PaperCellController" bundle:NULL];
    if(self) {
        self.entity = aEntity;
        self.delegate = aDelegate;
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
    // Do any additional setup after loading the view from its nib.
    self.ddayLabel.text = @"D-99";
    self.titleLabel.text = self.entity.title;
    UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTap)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
}
-(void) onTap {
    [self.delegate PaperCellTouched:self];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
