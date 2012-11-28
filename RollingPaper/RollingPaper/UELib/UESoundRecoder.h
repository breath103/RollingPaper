//
//  UESoundRecoder.h
//  RollingPaper
//
//  Created by 이상현 on 12. 11. 24..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>
@interface UESoundRecoder : NSObject<AVAudioRecorderDelegate>
@property (nonatomic,strong) NSString *soundFilePath;
@property (nonatomic,strong) AVAudioRecorder *audioRecorder;
-(void)startRecoding;
-(void)stopRecording;

@end

