//
//  NetworkTemplate.h
//  RollingPaper
//
//  Created by 이상현 on 12. 11. 4..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import "ASI/ASIFormDataRequest.h"
#import "ImageContent.h"

#define SERVER_IP   (@"172.16.10.194:8001")
#define SERVER_HOST ([@"http://" stringByAppendingString:SERVER_IP])



@interface NetworkTemplate : NSObject
// 로그인 / 회원가입 관련 리퀘스트들
+(ASIFormDataRequest*) requestForFacebookJoinWithMe : (id<FBGraphUser>) me
                                        accessToken : (NSString*) accesstoken;
// 방생성, 조회, 초대 관련 리퀘스트들
+(ASIFormDataRequest*) requestForCreateRollingPaperWithUserIdx : (NSString*) creator_idx
                                                         title : (NSString*) title
                                                  target_email : (NSString*) target_email
                                                        notice : (NSString*) notice
                                                  receiverFBid : (NSString*) receiver_fb_id
                                                  receiverName : (NSString*) receiver_name
                                                  receieveTime : (NSString*) receiveTime;
+(ASIFormDataRequest*) requestForRollingPaperListWithUserIdx : (NSString*) useridx;
+(ASIFormDataRequest*) requestForRollingPaperContents : (NSString*) paper_idx
                                            afterTime : (long) timestamp;
+(ASIFormDataRequest*) requestForInviteFacebookFriends : (NSArray*) facebookFriends
                                               ToPaper : (NSString*) paper_idx
                                              withUser : (NSString*) userIdx;
// 컨텐츠 제작 관련 리퀘스트들
+(ASIFormDataRequest*) requestForUploadImageContentWithUserIdx : (NSString*) useridx
                                                        entity : (ImageContent*) entity
                                                         image : (NSData*) image;



@end
