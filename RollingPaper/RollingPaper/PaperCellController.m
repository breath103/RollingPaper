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

- (NSString*) ddayStringWithDate : (long long) timestamp {
    NSDate* currentDate = [NSDate date];
    NSDate* receiveDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
    int     ddayCount   = (int)[receiveDate timeIntervalSinceDate:currentDate] / 60 / 60 / 24;
    
    NSString* ddayString;
    if(ddayCount == 0)     ddayString = @"D-DAY";
    else if(ddayCount > 0) ddayString = [NSString stringWithFormat:@"D-%d",abs(ddayCount)];
    else                   ddayString = [NSString stringWithFormat:@"D+%d",abs(ddayCount)];

    return ddayString;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    self.ddayLabel.text = [self ddayStringWithDate:self.entity.receive_time.longLongValue];
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
