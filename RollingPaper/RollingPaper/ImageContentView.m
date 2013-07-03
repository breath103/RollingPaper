#import "ImageContentView.h"
#import <JSONKit.h>
#import "UEFileManager.h"
#import "macro.h"
#import "CGPointExtension.h"
#import "FlowithAgent.h"
#import "UIImageView+Vingle.h"

@implementation ImageContentView
@synthesize isNeedToSyncWithServer;
-(id) initWithEntity : (ImageContent*) entity{
    self = [self initWithFrame:CGRectMake(0,0,1,1)];
    if(self){
        _imageView = [[UIImageView alloc]initWithFrame:self.frame];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_imageView];
        
        self.entity = entity;
        self.userInteractionEnabled = TRUE;
        self.frame = CGRectMake(0,0,entity.width.floatValue , entity.height.floatValue);
        if(entity.image){
            [_imageView setImageWithURL:[entity image]
                             withFadeIn:0.1f];
        }
        self.contentMode = UIViewContentModeScaleToFill;
        [self updateViewWithEntity];
    }
    return self;
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
-(void) syncEntityWithServer : (void (^)(NSError * error,
                                         UIView<RollingPaperContentViewProtocol> *))callback{
    // 서버에서 받아온 것이고 숨겨진경우. 즉, 삭제 예약된 경우
    if(self.entity.id && self.hidden) {
        [_entity deleteFromServer:^{
            callback(NULL,self);
        } failure:^(NSError *error) {
            callback(error,self);
        }];
    }
    else{
        if(isNeedToSyncWithServer) {
            [self updateEntityWithView];
            if (!self.entity.image) {
                [_entity setImageData:UIImagePNGRepresentation([_imageView image])];
            } else { }
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
-(NSNumber*) getUserIdx
{
    return self.entity.user_id;
}

@end
