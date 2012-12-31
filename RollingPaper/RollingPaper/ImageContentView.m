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
#import "UEFileManager.h"
#import "macro.h"
#import "CGPointExtension.h"

@implementation ImageContentView
@synthesize isNeedToSyncWithServer;
-(id) initWithEntity : (ImageContent*) entity{
    self = [self initWithFrame:CGRectMake(0,0,1,1)];
    if(self){
        self.entity = entity;
        self.frame = CGRectMake(0,0,entity.width.floatValue , entity.height.floatValue);
        if(entity.image){
            NSString* urlString = [entity.image stringByReplacingOccurrencesOfString:@"localhost" withString:SERVER_IP];
            //우선 이미지를 파일에서 읽어본다
            NSData* imageData = [UEFileManager readDataFromLocalFile:
                                 [self urlToLocalFilePath:urlString]];
            if(!imageData) //이미지가 로컬에 없는경우
            {
                NSLog(@"%@이미지가 로컬에 없음",urlString);
                self.image = [self loadImageFromURLAndSaveToLocalStorage:urlString];
            
            }else{
                self.image = [UIImage imageWithData:imageData];
            }
        }
        self.contentMode = UIViewContentModeScaleToFill;
        [self updateViewWithEntity];
    }
    return self;
}
-(NSString*) urlToLocalFilePath : (NSString*) url{
    NSArray* array = [url componentsSeparatedByString:@"/"];
    return [array lastObject];
}
-(UIImage*) loadImageFromURLAndSaveToLocalStorage : (NSString*) url{
    UIImage* image = [UEImageLibrary imageWithURL:url];
    NSString* localPath = [self urlToLocalFilePath:url];
    if ( image )
    {
        NSData *imageData = UIImagePNGRepresentation(image);
        [UEFileManager writeData : imageData
                     ToLocalFile : localPath];
        return image;
    }
    else
    {
        return NULL;
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
        if(self.entity.image == NULL)
        {
            NSData* jpegImage = UIImagePNGRepresentation(self.image);
            
            [self updateEntityWithView];
            ASIFormDataRequest* request = [NetworkTemplate requestForUploadImageContentWithUserIdx : [UserInfo getUserIdx].stringValue
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
        //원래 존재하는 엔티티인데, 값이 수정된경우
        else{
            [self updateEntityWithView];
            ASIFormDataRequest* request = [NetworkTemplate requestForSynchronizeImageContent:self.entity];
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
-(NSNumber*) getUserIdx{
    return self.entity.user_idx;
}

@end
