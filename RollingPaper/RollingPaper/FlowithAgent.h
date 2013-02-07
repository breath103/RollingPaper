//
//  FlowithAgent.h
//  RollingPaper
//
//  Created by 이상현 on 13. 1. 27..
//  Copyright (c) 2013년 상현 이. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

#define SERVER_IP   (@"210.122.0.119:8001")
#define SERVER_HOST ([@"http://" stringByAppendingString:SERVER_IP])


@class RollingPaper;
@class ImageContent;
@class SoundContent; 

@interface FlowithAgent : NSObject

+(FlowithAgent*) sharedAgent;

-(void) setUserInfo : (NSDictionary*) dict;
-(NSDictionary*) getUserInfo;
-(NSNumber*) getUserIdx;

/*
 
 이함수부터 수정해야댐 2월 3일 여기까지함
 
 */
-(void) joinWithFacebook :(id<FBGraphUser>) me
             accessToken : (NSString*) accesstoken
                 success : (void(^)(NSDictionary* response)) success
                 failure : (void(^)(NSError* error)) error;


-(void) getProfileImage : (void(^)(BOOL isCachedResponse,UIImage* image)) success;
-(void) getImageFromURL : (NSString*)url
                success : (void(^)(BOOL isCachedResponse,UIImage* image)) success;

// BACKGROUND METHOD
-(void) getBackgroundList : (void (^)(BOOL isCaschedResponse, NSArray * backgroundList))callback
                  failure : (void (^)(NSError* error))failure;
-(void) getBackground : (NSString*) background
             response : (void(^)(BOOL isCachedResponse,UIImage* image)) response;
/////////////////////

// USER - CONNECTION PAPER
-(void) getParticipaitingPapers : (void (^)(BOOL isCachedResponse,NSArray* paperArray))success
                        failure : (void (^)(NSError* error))failure ;
-(void) getReceivedPapers : (void (^)(BOOL isCachedResponse,NSArray* paperArray))callback
                  failure : (void (^)(NSError* error))failure ;
-(void) getSendedPapers : (void (^)(BOOL isCachedResponse,NSArray* paperArray))callback
                failure : (void (^)(NSError* error))failure ;


// PAPER
-(void) createPaper : (RollingPaper*) paper
            success : (void (^)(RollingPaper* paper))success
            failure : (void (^)(NSError* error))failure;
-(void) updatePaper : (RollingPaper*) paper
            success : (void (^)(RollingPaper* paper))success
            failure : (void (^)(NSError* error))failure;
-(void) getContentsOfPaper : (RollingPaper*) paper
                 afterTime : (long long) timestamp
                   success : (void (^)(BOOL isCachedResponse,NSArray* imageContents,
                                                             NSArray* soundContents))success
                   failure : (void (^)(NSError* error))failure;
-(void) getPaperParticipants : (RollingPaper*) paper
                     success : (void (^)(BOOL isCachedResponse,NSArray* participants))success
                     failure : (void (^)(NSError* error))failure;
//Contents
-(void) insertImageContent : (ImageContent*) imageContent
                     image : (NSData*) image
                   success : (void (^)(ImageContent* insertedImageContent))success
                   failure : (void (^)(NSError* error))failure;

-(void) insertSoundContent : (SoundContent*) soundContent
                     sound : (NSData*) sound
                   success : (void (^)(SoundContent* insertedSoundContent))success
                   failure : (void (^)(NSError* error))failure;

-(void) updateImageContent : (ImageContent*) entity
                   success : (void (^)(ImageContent* updatedImageContent))success
                   failure : (void (^)(NSError* error))failure;
-(void) updateSoundContent : (SoundContent*) entity
                   success : (void (^)(SoundContent* updatedSoundContent))success
                   failure : (void (^)(NSError* error))failure;

-(void) deleteImageContent : (ImageContent*) imageContent
                   success : (void (^)())success;
-(void) deleteSoundContent : (SoundContent*) imageContent
                   success : (void (^)())success;


// NOTICE
-(void) getNoticeList : (void (^)(BOOL isCaschedResponse, NSArray * noticeList))success
              failure : (void (^)(NSError* error))failure;


@end
