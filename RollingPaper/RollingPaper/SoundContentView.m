//
//  SoundContentView.m
//  RollingPaper
//
//  Created by 이상현 on 12. 11. 24..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "SoundContentView.h"
#import "NetworkTemplate.h"
#import "SBJSON.h"
#import "UserInfo.h"
#import "UECoreData.h"
@implementation SoundContentView
@synthesize isNeedToSyncWithServer;
@synthesize rotation;
@synthesize entity;
-(id) initWithEntity : (SoundContent*) aEntity{
    self = [self initWithFrame:CGRectMake(0,0,1,1)];
    if(self){
        self.entity = aEntity;
        self.userInteractionEnabled = TRUE;
        self.frame = CGRectMake(entity.x.floatValue, entity.y.floatValue,
                                SOUND_CONTENT_WIDTH,SOUND_CONTENT_HEIGHT);
        
        if(entity.sound){
            self.image = [UIImage imageNamed:@"sound_icon.png"];
            NSString* urlString = [entity.sound stringByReplacingOccurrencesOfString:@"localhost" withString:SERVER_IP];
            NSLog(@"%@",urlString);
            NSError* error;
            NSData* soundData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
            audioPlayer = [[AVAudioPlayer alloc] initWithData:soundData
                                                        error:&error];
            NSLog(@"%@",error);
        }
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTouchView)];
        [self addGestureRecognizer: tapGesture];
    }
    return self;
}
-(void) onTouchView{
    if(audioPlayer && !audioPlayer.playing){
        [audioPlayer play];
    }
    else {
        [audioPlayer stop];
    }
}
-(void) syncEntityWithServer{
    if(isNeedToSyncWithServer) {
        //회전하면 원점이 로테이션한 뷰를 포함하는 사각형의 왼쪽위가 되기때문에 센터 포인트 기준으로 다시 계산해야 한다.
        self.entity.x = [NSNumber numberWithFloat:self.center.x];
        self.entity.y = [NSNumber numberWithFloat:self.center.y];
        ASIFormDataRequest* request = [NetworkTemplate requestForUploadSoundContentWithUserIdx:[UserInfo getUserIdx]
                                                                                        entity:self.entity
                                                                                         sound:[NSData dataWithContentsOfFile:self.entity.sound]];
        [request setCompletionBlock:^{
            NSDictionary* dict = [[[SBJSON alloc] init] objectWithString:request.responseString];
            NSLog(@"%@",dict);
            [self.entity setValuesWithDictionary:dict];
            NSLog(@"%@",self.entity);
        }];
        [request setFailedBlock:^{
            NSLog(@"%@",@"fail!!!!");
        }];
        [request startAsynchronous];
        isNeedToSyncWithServer = FALSE;
    }
}

@end
