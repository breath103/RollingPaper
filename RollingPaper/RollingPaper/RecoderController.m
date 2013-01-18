//
//  RecoderViewController.m
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 14..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "RecoderController.h"
#import "UEUI.h"
#import <AVFoundation/AVFoundation.h>
#import "UEFileManager.h"

#define DEFAULT_DURATION (0.3f)

@implementation RecoderController
@synthesize recoder;
@synthesize delegate;
@synthesize audioPlayer;

- (IBAction)onTouchRecoding:(id)sender {
    if( ! self.recoder.audioRecorder.isRecording){
        [self.recoder startRecoding];
        
        [self.recodingButton fadeOut:DEFAULT_DURATION];
        [self.stopButton fadeIn:DEFAULT_DURATION];

        
        [self.recodingCircle fadeIn:DEFAULT_DURATION];
        
        self.recodingCircleGlow.hidden = FALSE;
        [UIView animateWithDuration:DEFAULT_DURATION * 2
                              delay:0
                            options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat
                         animations:^{
                             self.recodingCircleGlow.alpha = 1.0f;
                         } completion:^(BOOL finished) {
                            
                         }];
    }
}

- (IBAction)onTouchStop:(id)sender {
    if( self.recoder.audioRecorder.isRecording){
        [self.recoder stopRecording];
        NSData* soundData = [NSData dataWithContentsOfFile:self.recoder.soundFilePath];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithData:soundData
                                                         error:NULL];
        self.audioPlayer.delegate = self;
        [self.recodingCircle fadeOut:DEFAULT_DURATION];
        self.recodingCircleGlow.hidden = FALSE;
        [UIView animateWithDuration:DEFAULT_DURATION
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.recodingCircleGlow.alpha = 0.0f;
                         } completion:^(BOOL finished) {
                             self.recodingCircleGlow.hidden = TRUE;
                         }];
        
        [self.stopButton fadeOut:DEFAULT_DURATION];
        [self.playButton fadeIn:DEFAULT_DURATION];
    }
}
- (IBAction)onTouchPlay:(id)sender {
    // 여기에 녹음된 사운드를 재생하는 부분을 넣는다.
    [self.audioPlayer play];
    [self.recodingCircle fadeIn:DEFAULT_DURATION];
}

- (IBAction)onTouchDone:(id)sender {
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

- (IBAction)onTouchCancel:(id)sender {
    [UIView animateWithDuration:1.0f
                     animations:^{
                         self.view.alpha = 0.0f;
                     } completion:^(BOOL finished) {
                         [self.view removeFromSuperview];
                         [self removeFromParentViewController];
                     }];
}

-(id) initWithDelegate : (id<RecoderViewControllerDelegate>) aDelegate{
    self = [self initWithNibName:NSStringFromClass(self.class) bundle:NULL];
    if(self){
        self.recoder  = [[UESoundRecoder alloc]init];
        self.delegate = aDelegate;
    }
    return self;
}
-(void) hideButton : (UIView*) view{
    view.alpha = 0.0f;
    view.hidden = TRUE;
}

-(void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
                       successfully:(BOOL)flag{
    [self.recodingCircle fadeOut:DEFAULT_DURATION];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self hideButton:self.recodingCircle];
    [self hideButton:self.recodingCircleGlow];
    [self hideButton:self.stopButton];
    [self hideButton:self.playButton];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
