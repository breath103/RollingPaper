//
//  NetworkTemplate.h
//  RollingPaper
//
//  Created by 이상현 on 12. 11. 4..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import "ImageContent.h"
#import "SoundContent.h"
#import <ASIFormDataRequest.h>

#define SERVER_IP   (@"210.122.0.119:8001")
#define SERVER_HOST ([@"http://" stringByAppendingString:SERVER_IP])

@interface NetworkTemplate : NSObject
// 로그인 / 회원가입 관련 리퀘스트들
+(ASIFormDataRequest*) requestForPhoneAuth : (NSString*) phone;
+(ASIFormDataRequest*) requestForEditRollingPaper : (RollingPaper*) paper;

// 방생성, 조회, 초대 관련 리퀘스트들
+(ASIFormDataRequest*) requestForInviteFacebookFriends : (NSArray*) facebookFriends
                                               ToPaper : (NSString*) paper_idx
                                              withUser : (NSString*) userIdx;

+(ASIFormDataRequest*) requestForSearchingFacebookFriendUsingRollingPaper : (NSString*) useridx;

+(ASIFormDataRequest*) requestForSynchronizePaper : (RollingPaper*) entity;
+(ASIFormDataRequest*) requestForQuitRoomWithUserIdx : (NSString*) user_idx
                                               paper : (NSString*) paper_idx;
@end
