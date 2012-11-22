//
//  AssetLoader.h
//  Madeleine
//
//  Created by 상현 이 on 12. 3. 29..
//  Copyright (c) 2012년 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@class ALAssetsLibrary;

@interface UEAssets : NSObject
{
    ALAssetsLibrary* assetsLibrary;
}
@property (nonatomic,strong)     ALAssetsLibrary* assetsLibrary;

+ (ALAssetsLibrary *)defaultAssetsLibrary;
-(void) assetsGroupsWithType : (ALAssetsGroupType) type  groupArray : (NSMutableArray*) aGroupArray;
-(void) assetsInGroup        : (ALAssetsGroup*)    group assetArray : (NSMutableArray*) aAssetArray;
@end



@class UEAssetsScanner;
@protocol UEAssetsScannerDelegate <NSObject>
-(void)UEAssetsScanner : (UEAssetsScanner*) scanner
          didScanEnded : (NSMutableArray*) resultArray;
@end

@interface UEAssetsScanner : NSObject
{
    NSDate* startDate;
    NSDate* endDate;

    NSMutableArray* albumsArray;
    int scannedAlbumCount;
}
@property (nonatomic,readonly) NSMutableArray* resultAssets;
@property (nonatomic,weak) id<UEAssetsScannerDelegate> delegate;
-(id) initWithStartDate : (NSDate*) startDate
                endDate : (NSDate*) endDate
               delegate : (id) delegate;
-(void) startScan ;
@end

