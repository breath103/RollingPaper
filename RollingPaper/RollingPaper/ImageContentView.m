//
//  ImageContentView.m
//  RollingPaper
//
//  Created by 이상현 on 12. 11. 21..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "ImageContentView.h"
#import "UELib/UEImageLibrary.h"
#import "NetworkTemplate.h"
#import "UserInfo.h"
#import "UECoreData.h"
#import "SBJSON.h"

@implementation ImageContentView
@synthesize isNeedToSyncWithServer;
@synthesize rotation;
-(id) initWithEntity : (ImageContent*) entity{
    self = [self initWithFrame:CGRectMake(0,0,1,1)];
    if(self){
        self.entity = entity;
        
        self.frame = CGRectMake(entity.x.floatValue    , entity.y.floatValue,
                                entity.width.floatValue, entity.height.floatValue);
        if(entity.image){
            NSString* urlString = [entity.image stringByReplacingOccurrencesOfString:@"localhost" withString:SERVER_IP];
            self.image = [UEImageLibrary imageWithURL:urlString];
            NSLog(@"%@",urlString);
        }
        self.contentMode = UIViewContentModeScaleToFill;
        self.transform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(entity.rotation.floatValue),0,0);
    }
    return self;
}

-(void) syncEntityWithServer{
    if(isNeedToSyncWithServer) {
        // 서버로 이미지 컨텐츠를 전송하고, 서버로부터 결과값을 받아와 다시 엔티티에 넣고 이를 coreData에 저장하는 코드가 여기 들어간다.
        NSData* jpegImage = UIImagePNGRepresentation(self.image);//UIImageJPEGRepresentation(self.image, 0.3);
        
        NSNumber* angle  = (NSNumber *)[self valueForKeyPath:@"layer.transform.rotation.z"];
        float fAngle = -angle.floatValue;
        self.entity.rotation = angle;
        
        CGRect transformedBounds = CGRectApplyAffineTransform(self.bounds, self.transform);
        
        float rotatingScale = fabs(cos(fAngle)) + fabs(sin(fAngle)); // 회전하면서 키워진 바운드의 스케일.
        
        self.entity.width    = [NSNumber numberWithFloat:transformedBounds.size.width /rotatingScale];
        self.entity.height   = [NSNumber numberWithFloat:transformedBounds.size.height/rotatingScale];
        
        //회전하면 원점이 로테이션한 뷰를 포함하는 사각형의 왼쪽위가 되기때문에 센터 포인트 기준으로 다시 계산해야 한다.
        self.entity.x = [NSNumber numberWithFloat:self.center.x - self.entity.width.floatValue/2];
        self.entity.y = [NSNumber numberWithFloat:self.center.y - self.entity.height.floatValue/2];
        
        ASIFormDataRequest* request = [NetworkTemplate requestForUploadImageContentWithUserIdx : [UserInfo getUserIdx]
                                                                                        entity : self.entity
                                                                                         image : jpegImage];
        [request setCompletionBlock:^{
            NSDictionary* dict = [[[SBJSON alloc] init] objectWithString:request.responseString];
            NSLog(@"%@",dict);
            [self.entity setValuesWithDictionary:dict];
            NSLog(@"%@",self.entity);
        }];
        [request setFailedBlock:^{
            NSLog(@"%@",@"fail!!!!");
        }];
        
        [request startSynchronous];
        isNeedToSyncWithServer = false;
    }
}

@end
