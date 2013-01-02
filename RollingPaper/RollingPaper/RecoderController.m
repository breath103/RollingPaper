//
//  RecoderViewController.m
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 14..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "RecoderController.h"

@implementation RecoderController
@synthesize recoder;
@synthesize delegate;
-(id) initWithDelegate : (id<RecoderViewControllerDelegate>) aDelegate{
    self = [self initWithNibName:NSStringFromClass(self.class) bundle:NULL];
    if(self){
        self.recoder  = [[UESoundRecoder alloc]init];
        self.delegate = aDelegate;
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

- (IBAction)onTouchButton:(id)sender {
    if( ! self.recoder.audioRecorder.isRecording){
        [self.recoder startRecoding];
        [self.recodeButton setTitle:@"recording.."
                           forState:UIControlStateNormal];
    }
    else {
        [self.recoder stopRecording];
        [self.recodeButton setTitle:@"Stoped"
                           forState:UIControlStateNormal];
    
        [self.delegate recoderViewController : self
                       onEndRecodingWithFile : self.recoder.soundFilePath];
        [UIView animateWithDuration:1.0f
                         animations:^{
                             self.view.alpha = 0.0f;
                         } completion:^(BOOL finished) {
                             [self.view removeFromSuperview];
                             [self removeFromParentViewController];
                         }];
    }
}
- (void)viewDidUnload {
    [self setRecodeButton:nil];
    [super viewDidUnload];
}
@end
