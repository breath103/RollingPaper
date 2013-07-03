#import "SoundContentView.h"
#import "UECoreData.h"
#import "UEFileManager.h"
#import "macro.h"
#import "CGPointExtension.h"
#import <JSONKit.h>
#import "FlowithAgent.h"

@implementation SoundContentView
@synthesize isNeedToSyncWithServer;
-(id) initWithEntity : (SoundContent*) aEntity{
    self = [self initWithFrame:CGRectMake(0,0,1,1)];
    if(self){
        _entity = aEntity;
        self.userInteractionEnabled = TRUE;
        self.frame = CGRectMake(0,0,SOUND_CONTENT_WIDTH,SOUND_CONTENT_HEIGHT);
        if([_entity sound]){
            self.image = [UIImage imageNamed:@"sound_icon.png"];
            NSData *soundData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[_entity sound]]];
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
-(void) onTouchView{
    if (audioPlayer&&!audioPlayer.playing) {
        [audioPlayer play];
    }
    else {
        [audioPlayer stop];
    }
}
-(void) updateViewWithEntity{
    self.center = ccp( self.entity.x.floatValue,
                       self.entity.y.floatValue );
    
    CGRect bounds = self.bounds;
    bounds.size = CGSizeMake(SOUND_CONTENT_WIDTH,SOUND_CONTENT_HEIGHT);
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
-(void) syncEntityWithServer: (void (^)(NSError * error, UIView<RollingPaperContentViewProtocol> *))callback
{
    if(self.entity.id && self.hidden) {
        [_entity deleteFromServer:^{
            callback(NULL,self);
        } failure:^(NSError *error) {
            callback(error,self);
        }];
    }
    else{
        if([self isNeedToSyncWithServer]) {
            [self updateEntityWithView];
            if (![_entity id]) {
                [_entity setSoundData:[NSData dataWithContentsOfFile:self.entity.sound]];
            }
            [_entity saveToServer:^{
                callback(NULL,self);
            } failure:^(NSError *error) {
                callback(error,self);
            }];
            isNeedToSyncWithServer = NO;
        }
        else {
            //할일이 전혀 없는경우
            callback(NULL,self);
        }
    }
}
- (NSNumber *)getUserIdx
{
    return self.entity.user_id;
}
@end
