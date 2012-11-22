//
//  AssetLoader.m
//  Madeleine
//
//  Created by 상현 이 on 12. 3. 29..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import "UEAssets.h"

@implementation UEAssets
@synthesize assetsLibrary;

-(id) init
{
    self = [super init];
    if(self)
    {
        self.assetsLibrary = [[ALAssetsLibrary alloc]init];
    
    }
    return self;
}




+ (ALAssetsLibrary *)defaultAssetsLibrary {
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}



-(void) assetsGroupsWithType : (ALAssetsGroupType) type  groupArray : (NSMutableArray*) aGroupArray;
{
    [assetsLibrary enumerateGroupsWithTypes:type
                                 usingBlock:
     ^(ALAssetsGroup *group, BOOL *stop) {
         NSLog(@"--%@",group);
         if(group)
             [aGroupArray addObject:group];
         else {
             return ;
         }
     } failureBlock:^(NSError *error) {
         NSLog(@"++%@",error);
     }];
}
-(void) assetsInGroup        : (ALAssetsGroup*)    group assetArray : (NSMutableArray*) aAssetArray;
{
    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop){
        if(result)
            [aAssetArray addObject:result];
    }];
}
@end




@implementation UEAssetsScanner
@synthesize delegate;
@synthesize resultAssets;
-(id) initWithStartDate : (NSDate *)pStartDate
                endDate : (NSDate *)pEndDate
               delegate : (id) pDelegate
{
    self = [super init];
    if(self){
        startDate = pStartDate;
        endDate   = pEndDate;
        resultAssets = [NSMutableArray new];
        delegate = pDelegate;
        
        albumsArray = [NSMutableArray new];
    }
    return self;
}

-(void) startScan {
    ALAssetsLibrary* assetsLibrary = [UEAssets defaultAssetsLibrary];
    
    
    [assetsLibrary enumerateGroupsWithTypes : ALAssetsGroupAll
                                 usingBlock : ^(ALAssetsGroup *group, BOOL *stop){
                                     if(group){
                                         [albumsArray addObject:group];
                                     }
                                     else{
                                         [self onAlbumScanEnded];
                                     }
                                 }
                               failureBlock : ^(NSError *error) {
                                   NSLog(@"-%@",error);
                               }];
    NSLog(@"---%@",resultAssets);
}
-(void) onAlbumScanEnded {
    for(ALAssetsGroup* group in albumsArray){
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop){
            if(result)
            {
                NSDate * dateTime = [result valueForProperty:ALAssetPropertyDate];
                if([startDate compare:dateTime] == NSOrderedAscending &&
                   [endDate   compare:dateTime] == NSOrderedDescending){
                
                    NSString* assetType = [result valueForProperty:ALAssetPropertyType];
                
                    //일단은 사진만 추가
                    if( [assetType compare:@"ALAssetTypePhoto"] == NSOrderedSame){
                        [resultAssets addObject:result];
                    }
                    else {
                        //NSLog(@"%@",assetType);
                    }
                }
            }
            else
            {
                [self onPhotoScanEnded];
            }
        }];
    }
}
-(void) onPhotoScanEnded
{
    if(++scannedAlbumCount >= albumsArray.count){
        //모든 앨범들에 대한 스캔이 끝남
        [self.delegate UEAssetsScanner : self
                          didScanEnded : resultAssets];
    }
}
@end




