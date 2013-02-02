//
//  NetworkTemplate.m
//  RollingPaper
//
//  Created by 이상현 on 12. 11. 4..
//  Copyright (c) 2012년 상현 이. All rights reserved.
//

#import "NetworkTemplate.h"
#import <JSONKit.h>
#import "UEFileManager.h"
#import "RollingPaper.h"

@implementation NetworkTemplate

+(ASIFormDataRequest*) requestForPhoneAuth : (NSString*) phone{
    NSString* phoneAuthURL = [SERVER_HOST stringByAppendingString:@"/user/phoneAuth"];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:phoneAuthURL]];
    
    [request addPostValue:phone forKey:@"phone"];
    
    return request;
}
+(ASIFormDataRequest*) requestForFacebookJoinWithMe : (id<FBGraphUser>) me
                                        accessToken : (NSString*) accesstoken{
    NSLog(@"%@",SERVER_HOST);
    NSString* joinWithFacebookURL = [SERVER_HOST stringByAppendingString:@"/user/joinWithFacebook"];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:joinWithFacebookURL]];
    
    [request addPostValue:[me id]                    forKey:@"facebook_id"];
    [request addPostValue:[me objectForKey:@"name"]  forKey:@"name"];
    [request addPostValue:[me objectForKey:@"email"] forKey:@"email"];
    
    //생일부분이 mysql에는 yyyy-mm-dd 으로 넣어야 하는데 올때는 mm/dd/yyyy로온다. 이걸 재정렬
    NSString* birthdayString = [me objectForKey:@"birthday"];
    NSArray* dateComponent = [birthdayString componentsSeparatedByString:@"/"];
    birthdayString = [NSString stringWithFormat:@"%@-%@-%@",
                      [dateComponent objectAtIndex:2],
                      [dateComponent objectAtIndex:0],
                      [dateComponent objectAtIndex:1]];
    
    [request addPostValue:birthdayString forKey:@"birthday"];
    [request addPostValue: [[((NSDictionary*)[me objectForKey:@"picture"])objectForKey:@"data"] objectForKey:@"url"]  forKey:@"picture"];
    [request addPostValue:accesstoken forKey:@"facebook_accesstoken"];
    
    return request;
}
+(ASIFormDataRequest*) requestForUploadImageContentWithUserIdx : (NSString*) useridx
                                                        entity : (ImageContent*) entity
                                                         image : (NSData*) image{
    NSString* joinWithFacebookURL = [SERVER_HOST stringByAppendingString:@"/paper/addContent/image"];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:joinWithFacebookURL]];
  
    [request addPostValue:useridx           forKey:@"user_idx"];
    [request addPostValue:entity.paper_idx  forKey:@"paper_idx"];
    [request setData : image
        withFileName : @"photo1.png"
      andContentType : @"image/png"
              forKey : @"image"];
    
    [request addPostValue:entity.x        forKey:@"x"];
    [request addPostValue:entity.y        forKey:@"y"];
    [request addPostValue:entity.width    forKey:@"width"];
    [request addPostValue:entity.height   forKey:@"height"];
    [request addPostValue:entity.rotation forKey:@"rotation"];

    return request;
}

+(ASIFormDataRequest*) requestForEditRollingPaper : (RollingPaper*) paper{
    NSString* targetURL = [SERVER_HOST stringByAppendingString:@"/paper/edit"];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:targetURL]];
    
    [request addPostValue:paper.idx.stringValue forKey:@"paper_idx"];
    [request addPostValue:paper.title           forKey:@"title"];
    [request addPostValue:paper.target_email    forKey:@"target_email"];
    [request addPostValue:paper.notice          forKey:@"notice"];
    [request addPostValue:paper.background      forKey:@"background"];
    
    return request;
}
+(ASIFormDataRequest*) requestForCreateRollingPaperWithUserIdx : (NSString*) creator_idx
                                                         title : (NSString*) title
                                                  target_email : (NSString*) target_email
                                                        notice : (NSString*) notice
                                                  receiverFBid : (NSString*) receiver_fb_id
                                                  receiverName : (NSString*) receiver_name
                                                  receieveTime : (NSString*) receiveTime
                                                    background : (NSString*) background{
    NSString* targetURL = [SERVER_HOST stringByAppendingString:@"/paper/create"];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:targetURL]];
    
    [request addPostValue:creator_idx     forKey:@"creator_idx"];
    [request addPostValue:title           forKey:@"title"];
    [request addPostValue:target_email    forKey:@"target_email"];
    [request addPostValue:notice          forKey:@"notice"];
    [request addPostValue:receiver_fb_id  forKey:@"r_fb_id"];
    [request addPostValue:receiver_name   forKey:@"r_name"];
    [request addPostValue:receiveTime     forKey:@"r_time"];
    [request addPostValue:background      forKey:@"background"];
    
    NSLog(@"%@",request.postBody);
    return request;
}
+(ASIFormDataRequest*) requestForInviteFacebookFriends : (NSArray*) facebookFriends
                                               ToPaper : (NSString*) paper_idx
                                              withUser : (NSString*) user_idx{
    NSString* targetURL = [SERVER_HOST stringByAppendingString:@"/paper/inviteWithFacebookID"];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:targetURL]];
    
    [request addPostValue:paper_idx forKey:@"paper_idx"];
    [request addPostValue:user_idx  forKey:@"user_idx"];
    [request addPostValue:[facebookFriends JSONString] forKey:@"facebook_friends"];
    return request;
}
+(ASIFormDataRequest*) requestForRollingPaperContents : (NSString*) paper_idx
                                            afterTime : (long) timestamp {
    NSString* targetURL = [SERVER_HOST stringByAppendingString:@"/paper/contents"];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:targetURL]];
    
    [request addPostValue:paper_idx  forKey:@"paper_idx"];
    [request addPostValue:[NSString stringWithFormat:@"%ld",timestamp] forKey:@"after_time"];
    return request;
}
+(ASIFormDataRequest*) requestForUploadSoundContentWithUserIdx : (NSString*) useridx
                                                        entity : (SoundContent*) entity
                                                         sound : (NSData*) sound{
    NSString* requestURL = [SERVER_HOST stringByAppendingString:@"/paper/addContent/sound"];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestURL]];
    
    [request addPostValue:useridx           forKey:@"user_idx"];
    [request addPostValue:entity.paper_idx  forKey:@"paper_idx"];
    
    [request setData : sound
        withFileName : @"sound1.wav"
      andContentType : @"audio/wav"
              forKey : @"sound"];
    
    [request addPostValue:entity.x        forKey:@"x"];
    [request addPostValue:entity.y        forKey:@"y"];
    return request;
}


+(ASIFormDataRequest*) requestForSynchronizePaper : (RollingPaper*) entity{
    NSString* requestURL = [SERVER_HOST stringByAppendingString:@"/paper/edit"];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestURL]];
    /*
    [request addPostValue:entity.idx      forKey:@"idx"];
    [request addPostValue:entity.rotation forKey:@"rotation"];
    [request addPostValue:entity.width    forKey:@"width"];
    [request addPostValue:entity.height   forKey:@"height"];
    [request addPostValue:entity.x        forKey:@"x"];
    [request addPostValue:entity.y        forKey:@"y"];
    [request addPostValue:entity.image    forKey:@"image"];
     */
    return request;
}

// 컨텐츠 수정 관련 리퀘스트
+(ASIFormDataRequest*) requestForSynchronizeImageContent : (ImageContent*) entity{
    NSString* requestURL = [SERVER_HOST stringByAppendingString:@"/paper/editContent/image"];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestURL]];
    [request addPostValue:entity.idx      forKey:@"idx"];
    [request addPostValue:entity.rotation forKey:@"rotation"];
    [request addPostValue:entity.width    forKey:@"width"];
    [request addPostValue:entity.height   forKey:@"height"];
    [request addPostValue:entity.x        forKey:@"x"];
    [request addPostValue:entity.y        forKey:@"y"];
    [request addPostValue:entity.image    forKey:@"image"];
    return request;
    
}
+(ASIFormDataRequest*) requestForSynchronizeSoundContent : (SoundContent*) entity{
    NSString* requestURL = [SERVER_HOST stringByAppendingString:@"/paper/editContent/sound"];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestURL]];
    [request addPostValue:entity.idx      forKey:@"idx"];
    [request addPostValue:entity.rotation forKey:@"rotation"];
    [request addPostValue:entity.width    forKey:@"width"];
    [request addPostValue:entity.height   forKey:@"height"];
    [request addPostValue:entity.x        forKey:@"x"];
    [request addPostValue:entity.y        forKey:@"y"];
    [request addPostValue:entity.sound    forKey:@"sound"];
    return request;
}


+(ASIFormDataRequest*) requestForParticipantsListWithPaperIdx : (NSString*) paper_idx{
    NSString* requestURL = [SERVER_HOST stringByAppendingString:@"/paper/participants"];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestURL]];
    [request addPostValue:paper_idx forKey:@"paper"];
    return request;
}
+(ASIFormDataRequest*) requestForQuitRoomWithUserIdx : (NSString*) user_idx
                                               paper : (NSString*) paper_idx{
    NSString* requestURL = [SERVER_HOST stringByAppendingString:@"/paper/quit"];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestURL]];
    [request addPostValue:user_idx forKey:@"user"];
    [request addPostValue:paper_idx forKey:@"paper"];
    return request;
}

+(ASIFormDataRequest*) requestForSearchingFacebookFriendUsingRollingPaper : (NSString*) user_idx{
    NSString* requestURL = [SERVER_HOST stringByAppendingString:@"/user/isFacebookFriendUsingRollingPaper"];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestURL]];
    [request addPostValue:user_idx forKey:@"user_idx"];
    return request;
}



+(ASIFormDataRequest*) requestForDeleteImageContent : (NSString*) image_idx
                                        withUserIdx : (NSString*) user_idx{
    NSString* requestURL = [SERVER_HOST stringByAppendingString:@"/paper/deleteContent/image"];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestURL]];
    [request addPostValue:image_idx forKey:@"image_idx"];
    [request addPostValue:user_idx forKey:@"user_idx"];
    return request;
}
+(ASIFormDataRequest*) requestForDeleteSoundContent : (NSString*) sound_idx
                                        withUserIdx : (NSString*) user_idx{
    NSString* requestURL = [SERVER_HOST stringByAppendingString:@"/paper/deleteContent/sound"];
    ASIFormDataRequest* request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:requestURL]];
    [request addPostValue:sound_idx forKey:@"sound_idx"];
    [request addPostValue:user_idx forKey:@"user_idx"];
    return request;
}
+(void) getImageFromURL : (NSString*) url
            withHandler : (BackgroundImageHandler) handler{
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
    [request setCompletionBlock:^{
        UIImage* image = [UIImage imageWithData:request.responseData];
        handler(image);
    }];
    [request setFailedBlock:^{
        NSLog(@"%@",request);
    }];
    [request startAsynchronous];
}


@end
