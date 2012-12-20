//
//  ContentsToolDockController.m
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 16..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "ContentsToolDockController.h"

@interface ContentsToolDockController ()

@end

@implementation ContentsToolDockController
@synthesize delegate;
-(id) initWithDelegate : (id<ContentsToolDockControllerDelegate>) delegate{
    self = [self initWithNibName:@"ContentsToolDockController"
                          bundle:NULL];
    if(self){
        self.delegate = delegate;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
