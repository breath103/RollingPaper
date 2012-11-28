//
//  SoundContentView.h
//  RollingPaper
//
//  Created by 이상현 on 12. 11. 24..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundContent.h"
#import "RollingPaperContentViewProtocol.h"
#import <AVFoundation/AVFoundation.h>

#define SOUND_CONTENT_WIDTH  (50.0f)
#define SOUND_CONTENT_HEIGHT (50.0f)

@interface SoundContentView : UIImageView<RollingPaperContentViewProtocol>
{
    AVAudioPlayer* audioPlayer;
}
@property (strong,nonatomic) SoundContent* entity;
-(id) initWithEntity : (SoundContent*) entity;
@end
