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
#import "UEFileManager.h"
#import "macro.h"
#import "CGPointExtension.h"

@implementation SoundContentView
@synthesize isNeedToSyncWithServer;
@synthesize rotation;
@synthesize entity;
-(id) initWithEntity : (SoundContent*) aEntity{
    self = [self initWithFrame:CGRectMake(0,0,1,1)];
    if(self){
        self.entity = aEntity;
        self.userInteractionEnabled = TRUE;
        self.frame = CGRectMake(0,0,1,1);
        if(entity.sound){
            self.image = [UIImage imageNamed:@"sound_icon.png"];
            NSString* urlString = [entity.sound stringByReplacingOccurrencesOfString:@"localhost" withString:SERVER_IP];
            NSData* soundData = [UEFileManager readDataFromLocalFile:[self urlToLocalFilePath:urlString]];
            if( !soundData ){
                NSLog(@"%@사운드가 로컬에 없음",urlString);
                soundData = [self loadSoundFromURLAndSaveToLocalStorage:urlString];
            }
            audioPlayer = [[AVAudioPlayer alloc] initWithData:soundData
                                                        error:NULL];
        }
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTouchView)];
        [self addGestureRecognizer: tapGesture];
    
        self.contentMode = UIViewContentModeScaleToFill;
        [self updateViewWithEntity];
    }
    return self;
}
-(NSString*) urlToLocalFilePath : (NSString*) url{
    NSArray* array = [url componentsSeparatedByString:@"/"];
    return [array lastObject];
}
-(NSData*) loadSoundFromURLAndSaveToLocalStorage : (NSString*) url{
    NSData* soundData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    NSString* localPath = [self urlToLocalFilePath:url];
    if ( soundData ){
        [UEFileManager writeData : soundData
                     ToLocalFile : localPath];
        return soundData;
    }
    else{
        NSLog(@"RollingPaper서버에서 리소스 조회 실패 : %@",url);
        return NULL;
    };
}
-(void) onTouchView{
    NSLog(@"%@ : playSound",self);
    if(audioPlayer && !audioPlayer.playing){
        [audioPlayer play];
    }
    else {
        [audioPlayer stop];
    }
}
-(void) updateViewWithEntity{
    self.center = ccp(self.entity.x.floatValue,self.entity.y.floatValue);
    
    CGRect bounds = self.bounds;
    bounds.size = CGSizeMake(self.entity.width.floatValue,self.entity.height.floatValue);
    self.bounds = bounds;
    self.transform = CGAffineTransformMakeRotation(self.entity.rotation.floatValue);
}
-(void) updateEntityWithView{
    NSNumber* angle  = (NSNumber *)[self valueForKeyPath:@"layer.transform.rotation.z"];
    NSNumber* scale  = (NSNumber *)[self valueForKeyPath:@"layer.transform.scale.x"];
    
    CGSize size = self.bounds.size;
    size.width  *= scale.floatValue;
    size.height *= scale.floatValue; //스케일 값을 곱해 실제 보이는 크기로 만든다.
    
    self.entity.rotation = angle;
    self.entity.width    = FLOAT_TO_NSNUMBER(size.width);
    self.entity.height   = FLOAT_TO_NSNUMBER(size.height);
    self.entity.x        = FLOAT_TO_NSNUMBER(self.center.x);
    self.entity.y        = FLOAT_TO_NSNUMBER(self.center.y);
}
-(void) syncEntityWithServer{
    if(isNeedToSyncWithServer) {
        if(self.entity.sound == NULL){
            [self updateEntityWithView];
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
        else {
            [self updateEntityWithView];
            ASIFormDataRequest* request = [NetworkTemplate requestForSynchronizeSoundContent:self.entity];
            [request setCompletionBlock:^{
                NSDictionary* dict = [[[SBJSON alloc] init] objectWithString:request.responseString];
                NSLog(@"%@",dict);
            }];
            [request setFailedBlock:^{
                NSLog(@"%@",@"fail!!!!");
            }];
            [request startSynchronous];
            isNeedToSyncWithServer = false;
        }
        
    }
}

@end
