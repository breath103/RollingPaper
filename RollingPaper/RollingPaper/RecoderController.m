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
#import "CGPointExtension.h"

#define DEFAULT_DURATION (0.3f)

@implementation RecoderController
@synthesize recoder;
@synthesize delegate;
@synthesize audioPlayer;

- (IBAction)onTouchRecoding:(id)sender {
    if( ! self.recoder.audioRecorder.isRecording){
        [self.recoder startRecoding];
        
        [self.playerContainer fadeOut:DEFAULT_DURATION];
        
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

-(NSString*) getEndTime{
    float duration = self.audioPlayer.duration;
    return [NSString stringWithFormat:@"%f:%f",floorf(duration),duration - floorf(duration)];
}
- (IBAction)onTouchStop:(id)sender {
    if( self.recoder.audioRecorder.isRecording){
        [self.recoder stopRecording];
        NSData* soundData = [NSData dataWithContentsOfFile:self.recoder.soundFilePath];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithData:soundData
                                                         error:NULL];
        self.audioPlayer.delegate = self;
        self.endTimeLabel.text = [self getEndTime];
        
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
        
        [self.recodingButton fadeIn:DEFAULT_DURATION];
        [self.stopButton fadeOut:DEFAULT_DURATION];
        
        [self.playerContainer fadeIn:DEFAULT_DURATION];
        //[self.playButton fadeIn:DEFAULT_DURATION];
    }
}
-(void) updateTimeline{
 /*
    self.timelineIndicator.center = ccpLerp(ccp(35,190),ccp(35+249,190),self.audioPlayer.currentTime/self.audioPlayer.duration);
    NSLog(@"%@",NSStringFromCGPoint(self.timelineIndicator.center));
    [self.timelineIndicator setNeedsDisplay];
  */
    self.audioNavigation.value = self.audioPlayer.currentTime / self.audioPlayer.duration;
    [self.audioNavigation setNeedsDisplay];
}
- (IBAction)onTouchPlay:(id)sender {
    // 여기에 녹음된 사운드를 재생하는 부분을 넣는다.
    [self.audioPlayer play];
    [self.playerCircleGlow fadeIn:DEFAULT_DURATION];
    
    if(self.timelineUpdatingTimer)
        [self.timelineUpdatingTimer invalidate];
    
    self.timelineUpdatingTimer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                                  target:self
                                                                selector:@selector(updateTimeline)
                                                                userInfo:nil
                                                                 repeats:YES];
    
    [self.playButton fadeOut:DEFAULT_DURATION];
    [self.pauseButton fadeIn:DEFAULT_DURATION];
}

- (IBAction)onTouchPause:(id)sender {
    if(self.audioPlayer.isPlaying)
    {
        [self.audioPlayer pause];
        [self.playButton   fadeIn:DEFAULT_DURATION];
        [self.pauseButton fadeOut:DEFAULT_DURATION];
        [self.playerCircleGlow fadeOut:DEFAULT_DURATION];
    }
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
    [self.delegate recoderViewControllerCancelRecoding:self];
}

- (IBAction)onAudioSliderChanged:(id)sender {
    
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
    [self.playerCircleGlow fadeOut:DEFAULT_DURATION];
    [self.pauseButton fadeOut:DEFAULT_DURATION];
    [self.playButton fadeIn:DEFAULT_DURATION];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self hideButton:self.recodingCircle];
    [self hideButton:self.recodingCircleGlow];
    [self hideButton:self.stopButton];
    [self hideButton:self.playerContainer];
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
