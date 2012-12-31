//
//  RollingPaperContentViewProtocol.h
//  RollingPaper
//
//  Created by 이상현 on 12. 11. 21..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RollingPaperContentViewProtocol <NSObject>
@property(atomic) bool isNeedToSyncWithServer;
#pragma mark - 서버에 이미 등록되어 있는 컨텐츠가 아니라, 사용자가 현재 새로만든 컨텐츠인경우 마지막에 저장시에 이 함수를 호출하면, 서버에 엔티티를 업로드 하고 엔티티 정보를 다시 서버로 부터 받아와 동기화한다.
-(void) syncEntityWithServer;
-(NSNumber*) getUserIdx;
@end