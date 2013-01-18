//
//  RecoderViewController.h
//  RollingPaper
//
//  Created by 이상현 on 12. 12. 14..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UESoundRecoder.h"

@class RecoderController;
@protocol RecoderViewControllerDelegate<NSObject>
-(void) recoderViewController : (RecoderController*) recoder
        onEndRecodingWithFile : (NSString*) file;
@end

@interface RecoderController : UIViewController<AVAudioPlayerDelegate>
@property (nonatomic,strong) UESoundRecoder* recoder;
@property (nonatomic,weak)   id<RecoderViewControllerDelegate> delegate;
@property (nonatomic,strong) AVAudioPlayer* audioPlayer;
@property (weak, nonatomic) IBOutlet UIImageView *recodingCircle;
@property (weak, nonatomic) IBOutlet UIImageView *recodingCircleGlow;
@property (weak, nonatomic) IBOutlet UIButton *recodingButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;

- (IBAction)onTouchRecoding:(id)sender;
- (IBAction)onTouchStop:(id)sender;
- (IBAction)onTouchPlay:(id)sender;
- (IBAction)onTouchDone:(id)sender;
- (IBAction)onTouchCancel:(id)sender;

-(id) initWithDelegate : (id<RecoderViewControllerDelegate>) aDelegate;
@end
