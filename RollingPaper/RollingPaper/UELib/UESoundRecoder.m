//
//  UESoundRecoder.m
//  RollingPaper
//
//  Created by 이상현 on 12. 11. 24..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "UESoundRecoder.h"

@implementation UESoundRecoder
@synthesize soundFilePath;
@synthesize audioRecorder;
-(id) init{
    self = [super init];
    if(self){
        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsDir = [dirPaths objectAtIndex:0];
        
        soundFilePath = [docsDir stringByAppendingPathComponent:@"sound.wav"];
        
        NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
        NSDictionary *recordSettings =  [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                         [NSNumber numberWithFloat:11025.0], AVSampleRateKey,
                                         [NSNumber numberWithInt: 1], AVNumberOfChannelsKey,
                                         [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                         nil];
        NSError *error = nil;
    
        audioRecorder = [[AVAudioRecorder alloc]
                         initWithURL:soundFileURL
                         settings:recordSettings
                         error:&error];
        audioRecorder.delegate = self;
    
        if (error){
            NSLog(@"error: %@", [error localizedDescription]);
        } else {
            [audioRecorder prepareToRecord];
        }
    }
    return self;
}
-(void)startRecoding
{
    if (!audioRecorder.recording)
    {
        [audioRecorder record];
    }
}
-(void)stopRecording
{
    if (audioRecorder.recording)
    {
        [audioRecorder stop];
    }
}
-(void)audioRecorderDidFinishRecording : (AVAudioRecorder *)recorder
                          successfully : (BOOL)flag
{
    NSLog(@"%@",recorder);
}
-(void)audioRecorderEncodeErrorDidOccur : (AVAudioRecorder *)recorder
                                  error : (NSError *)error
{
    NSLog(@"Encode Error occurred");
}
@end
