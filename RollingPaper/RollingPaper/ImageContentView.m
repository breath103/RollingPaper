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
        self.frame = CGRectMake(0,0,entity.width.floatValue , entity.height.floatValue);
        if(entity.image){
            NSString* urlString = [entity.image stringByReplacingOccurrencesOfString:@"localhost" withString:SERVER_IP];
            //우선 이미지를 파일에서 읽어본다
            self.image = [self loadImageFromLocalStorage: [self urlToLocalFilePath:urlString]];
            if(!self.image) //이미지가 로컬에 없는경우
            {
                NSLog(@"%@이미지가 로컬에 없음",urlString);
                self.image = [self loadImageFromURLAndSaveToLocalStorage:urlString];
            }
        }
        self.contentMode = UIViewContentModeScaleToFill;
        self.transform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(entity.rotation.floatValue),
                                                    entity.x.floatValue,
                                                    entity.y.floatValue);
    }
    return self;
}
-(NSString*) urlToLocalFilePath : (NSString*) url{
    NSArray* array = [url componentsSeparatedByString:@"/"];
    return array[array.count-1];
}
-(UIImage*) loadImageFromLocalStorage : (NSString*) url{
    UIImage* image = NULL;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,url];
    image = [UIImage imageWithContentsOfFile:filePath];
    return image;
}
-(UIImage*) loadImageFromURLAndSaveToLocalStorage : (NSString*) url{
    UIImage* image = [UEImageLibrary imageWithURL:url];
    NSString* localPath = [self urlToLocalFilePath:url];
    if ( image )
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,localPath];
        NSData *imageData = UIImagePNGRepresentation(image);
        if([imageData writeToFile:filePath
                       atomically:NO]){
            NSLog(@"%@ saved",filePath);
        }
        else {
            NSLog(@"%@ save fail",filePath);
        }
        return image;
    }
    else
    {
        return NULL;
    }
}
-(void) syncEntityWithServer{
    if(isNeedToSyncWithServer) {
        // 서버로 이미지 컨텐츠를 전송하고,
        // 서버로부터 결과값을 받아와 다시 엔티티에 넣고 이를 coreData에 저장하는 코드가 여기 들어간다.
        NSData* jpegImage = UIImagePNGRepresentation(self.image);
        
        NSNumber* angle  = (NSNumber *)[self valueForKeyPath:@"layer.transform.rotation.z"];
        NSNumber* x      = (NSNumber *)[self valueForKeyPath:@"layer.transform.translation.x"];
        NSNumber* y      = (NSNumber *)[self valueForKeyPath:@"layer.transform.translation.y"];
        
        float fAngle = -angle.floatValue + 90;
        self.entity.rotation = angle;
        
        CGRect transformedBounds = CGRectApplyAffineTransform(self.bounds, self.transform);
        
        float rotatingScale = fabs(cos(fAngle)) + fabs(sin(fAngle)); // 회전하면서 키워진 바운드의 스케일.
        
        self.entity.width    = [NSNumber numberWithFloat:transformedBounds.size.width /rotatingScale];
        self.entity.height   = [NSNumber numberWithFloat:transformedBounds.size.height/rotatingScale];
        
        //회전하면 원점이 로테이션한 뷰를 포함하는 사각형의 왼쪽위가 되기때문에 센터 포인트 기준으로 다시 계산해야 한다.
        self.entity.x = x; //[NSNumber numberWithFloat:self.center.x - self.entity.width.floatValue/2];
        self.entity.y = y; //[NSNumber numberWithFloat:self.center.y - self.entity.height.floatValue/2];
        
        ASIFormDataRequest* request = [NetworkTemplate requestForUploadImageContentWithUserIdx : [UserInfo getUserIdx]
                                                                                        entity : self.entity
                                                                                         image : jpegImage];
        [request setCompletionBlock:^{
            NSDictionary* dict = [[[SBJSON alloc] init] objectWithString:request.responseString];
            [self.entity setValuesWithDictionary:dict];
        }];
        [request setFailedBlock:^{
            NSLog(@"%@",@"fail!!!!");
        }];
        [request startSynchronous];
        isNeedToSyncWithServer = false;
    }
}

@end
